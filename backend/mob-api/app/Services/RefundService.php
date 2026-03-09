<?php

namespace App\Services;

use App\Enums\EscrowAction;
use App\Enums\TicketStatus;
use App\Models\EscrowEventLog;
use App\Models\Ticket;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RefundService
{
    public function __construct(
        private readonly PaymentService $paymentService,
        private readonly EscrowService $escrowService,
    ) {}

    public function processRefund(Ticket $ticket): bool
    {
        if (! in_array($ticket->status, [TicketStatus::PAID, TicketStatus::REFUND_PROCESSING], true)) {
            return false;
        }

        $ticket->status = TicketStatus::REFUND_PROCESSING;
        $ticket->save();

        try {
            $this->paymentService->initiateRefund(
                $ticket->payment_reference,
                $ticket->payment_gateway,
                $ticket->amount
            );

            DB::transaction(function () use ($ticket) {
                $ticket->status = TicketStatus::REFUNDED;
                $ticket->refunded_at = now();
                $ticket->save();

                EscrowEventLog::create([
                    'escrow_id' => $ticket->escrow_id,
                    'action' => EscrowAction::TICKET_REFUNDED,
                    'performed_by_user_id' => null,
                    'performed_by_role' => 'system',
                    'metadata' => [
                        'ticket_uuid' => $ticket->uuid,
                        'amount' => $ticket->amount,
                    ],
                ]);
            });

            return true;
        } catch (\Throwable $e) {
            Log::error('Refund failed for ticket', [
                'ticket_uuid' => $ticket->uuid,
                'payment_reference' => $ticket->payment_reference,
                'gateway' => $ticket->payment_gateway->value,
                'amount' => $ticket->amount,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }

    public function processAllRefundsForEscrow(Escrow $escrow): array
    {
        $tickets = Ticket::where('escrow_id', $escrow->id)
            ->whereIn('status', [TicketStatus::PAID, TicketStatus::REFUND_PROCESSING])
            ->get();

        $succeeded = 0;
        $failed = 0;

        foreach ($tickets as $ticket) {
            if ($this->processRefund($ticket)) {
                $succeeded++;
            } else {
                $failed++;
            }
        }

        if ($failed === 0 && $succeeded > 0) {
            $escrow->refund_completed_at = now();

            $this->escrowService->transitionStatus(
                $escrow,
                EscrowStatus::REFUNDED,
                null,
                'system',
                ['action' => EscrowAction::REFUND_COMPLETED->value, 'tickets_refunded' => $succeeded]
            );
        }

        return [
            'total' => $tickets->count(),
            'succeeded' => $succeeded,
            'failed' => $failed,
        ];
    }

    public function retryFailedRefunds(Escrow $escrow): array
    {
        $tickets = Ticket::where('escrow_id', $escrow->id)
            ->where('status', TicketStatus::REFUND_PROCESSING)
            ->get();

        $succeeded = 0;
        $failed = 0;

        foreach ($tickets as $ticket) {
            if ($this->processRefund($ticket)) {
                $succeeded++;
            } else {
                $failed++;
            }
        }

        return [
            'total' => $tickets->count(),
            'succeeded' => $succeeded,
            'failed' => $failed,
        ];
    }
}
