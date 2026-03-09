<?php

namespace App\Services;

use App\Enums\EscrowAction;
use App\Enums\EscrowStatus;
use App\Enums\TicketStatus;
use App\Events\EscrowStatusChanged;
use App\Models\Escrow;
use App\Models\EscrowEventLog;
use App\Models\Happening;
use App\Models\Ticket;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class EscrowService
{
    public function getValidTransitions(): array
    {
        return [
            EscrowStatus::COLLECTING->value => [EscrowStatus::HELD, EscrowStatus::REFUNDING],
            EscrowStatus::HELD->value => [EscrowStatus::AWAITING_COMPLETION, EscrowStatus::REFUNDING],
            EscrowStatus::AWAITING_COMPLETION->value => [EscrowStatus::RELEASED, EscrowStatus::REFUNDING],
            EscrowStatus::RELEASED->value => [],
            EscrowStatus::REFUNDING->value => [EscrowStatus::REFUNDED],
            EscrowStatus::REFUNDED->value => [],
            EscrowStatus::DISPUTED->value => [EscrowStatus::REFUNDING, EscrowStatus::RELEASED],
        ];
    }

    public function canTransition(EscrowStatus $from, EscrowStatus $to): bool
    {
        $transitions = $this->getValidTransitions();

        $allowed = $transitions[$from->value] ?? [];

        return in_array($to, $allowed, true);
    }

    public function transitionStatus(Escrow $escrow, EscrowStatus $newStatus, ?User $performer, string $performerRole, ?array $metadata = null): Escrow
    {
        $previousStatus = $escrow->status;

        if (! $this->canTransition($previousStatus, $newStatus)) {
            throw new \InvalidArgumentException("Invalid escrow transition from {$previousStatus->value} to {$newStatus->value}");
        }

        $escrow->status = $newStatus;
        $escrow->save();

        $action = $this->resolveAction($previousStatus, $newStatus);

        EscrowEventLog::create([
            'escrow_id' => $escrow->id,
            'action' => $action,
            'performed_by_user_id' => $performer?->id,
            'performed_by_role' => $performerRole,
            'metadata' => $metadata,
        ]);

        event(new EscrowStatusChanged($escrow, $previousStatus, $newStatus));

        return $escrow;
    }

    public function createEscrow(Happening $happening): Escrow
    {
        if (! $happening->is_ticketed) {
            throw new \LogicException('Cannot create escrow for a non-ticketed happening');
        }

        if ($happening->escrow()->exists()) {
            throw new \LogicException('An escrow already exists for this happening');
        }

        $escrow = Escrow::create([
            'happening_id' => $happening->id,
            'host_id' => $happening->user_id,
            'status' => EscrowStatus::COLLECTING,
            'total_amount' => 0,
            'platform_fee' => 0,
            'host_payout_amount' => 0,
            'tickets_count' => 0,
        ]);

        EscrowEventLog::create([
            'escrow_id' => $escrow->id,
            'action' => EscrowAction::CREATED,
            'performed_by_user_id' => null,
            'performed_by_role' => 'system',
            'metadata' => ['happening_uuid' => $happening->uuid],
        ]);

        return $escrow;
    }

    public function addTicketToEscrow(Escrow $escrow, Ticket $ticket): void
    {
        DB::transaction(function () use ($escrow, $ticket) {
            $escrow->total_amount += $ticket->amount;
            $escrow->tickets_count += 1;
            $this->calculateFees($escrow);
            $escrow->save();

            EscrowEventLog::create([
                'escrow_id' => $escrow->id,
                'action' => EscrowAction::TICKET_ADDED,
                'performed_by_user_id' => $ticket->user_id,
                'performed_by_role' => 'buyer',
                'metadata' => [
                    'ticket_uuid' => $ticket->uuid,
                    'amount' => $ticket->amount,
                ],
            ]);
        });
    }

    public function calculateFees(Escrow $escrow): void
    {
        $commissionRate = config('mob.platform_commission_rate', 0.10);

        $escrow->platform_fee = round($escrow->total_amount * $commissionRate, 2);
        $escrow->host_payout_amount = round($escrow->total_amount - $escrow->platform_fee, 2);
    }

    public function markHostComplete(Escrow $escrow, User $host): Escrow
    {
        if ($escrow->host_id !== $host->id) {
            throw new \InvalidArgumentException('User is not the host of this escrow');
        }

        $happening = $escrow->happening;

        if ($happening->starts_at === null || $happening->starts_at->isFuture()) {
            throw new \LogicException('Cannot mark complete before event start time');
        }



        if ($escrow->status === EscrowStatus::COLLECTING) {
            $this->transitionStatus($escrow, EscrowStatus::HELD, null, 'system', [
                'reason' => 'Event start time reached (inline transition)',
            ]);
        }

        $escrow->host_completed_at = now();

        return $this->transitionStatus($escrow, EscrowStatus::AWAITING_COMPLETION, $host, 'host', [
            'action' => EscrowAction::HOST_MARKED_COMPLETE->value,
        ]);
    }

    public function adminApprove(Escrow $escrow, User $admin): Escrow
    {
        $escrow->admin_approved_at = now();
        $escrow->released_at = now();

        return $this->transitionStatus($escrow, EscrowStatus::RELEASED, $admin, 'admin', [
            'action' => EscrowAction::ADMIN_APPROVED->value,
        ]);
    }

    public function adminReject(Escrow $escrow, User $admin, string $reason): Escrow
    {
        $escrow->admin_notes = $reason;

        return $this->transitionStatus($escrow, EscrowStatus::REFUNDING, $admin, 'admin', [
            'action' => EscrowAction::ADMIN_REJECTED->value,
            'reason' => $reason,
        ]);
    }

    public function initiateRefunds(Escrow $escrow): Escrow
    {
        return DB::transaction(function () use ($escrow) {
            $escrow->refund_initiated_at = now();

            if (in_array($escrow->status, [EscrowStatus::COLLECTING, EscrowStatus::HELD], true)) {
                $this->transitionStatus($escrow, EscrowStatus::REFUNDING, null, 'system', [
                    'action' => EscrowAction::REFUND_INITIATED->value,
                ]);
            }

            Ticket::where('escrow_id', $escrow->id)
                ->where('status', TicketStatus::PAID)
                ->update(['status' => TicketStatus::REFUND_PROCESSING]);

            return $escrow;
        });
    }

    private function resolveAction(EscrowStatus $from, EscrowStatus $to): EscrowAction
    {
        return match (true) {
            $to === EscrowStatus::AWAITING_COMPLETION => EscrowAction::HOST_MARKED_COMPLETE,
            $to === EscrowStatus::RELEASED && $from === EscrowStatus::AWAITING_COMPLETION => EscrowAction::ADMIN_APPROVED,
            $to === EscrowStatus::RELEASED && $from === EscrowStatus::DISPUTED => EscrowAction::ADMIN_OVERRIDE,
            $to === EscrowStatus::REFUNDING && $from === EscrowStatus::AWAITING_COMPLETION => EscrowAction::ADMIN_REJECTED,
            $to === EscrowStatus::REFUNDING => EscrowAction::REFUND_INITIATED,
            $to === EscrowStatus::REFUNDED => EscrowAction::REFUND_COMPLETED,
            $to === EscrowStatus::HELD && $from === EscrowStatus::COLLECTING => EscrowAction::EVENT_STARTED,
            $to === EscrowStatus::HELD => EscrowAction::ADMIN_OVERRIDE,
            default => EscrowAction::ADMIN_OVERRIDE,
        };
    }
}
