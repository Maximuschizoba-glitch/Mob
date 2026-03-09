<?php

namespace App\Listeners;

use App\Enums\EscrowStatus;
use App\Enums\TicketStatus;
use App\Events\EscrowStatusChanged;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class SendEscrowNotification implements ShouldQueue
{
    public function __construct(
        private NotificationService $notificationService,
    ) {}

    public function handle(EscrowStatusChanged $event): void
    {
        $escrow = $event->escrow;
        $newStatus = $event->newStatus;
        $happening = $escrow->happening;

        $data = [
            'type' => 'escrow_status_changed',
            'escrow_uuid' => $escrow->uuid,
            'status' => $newStatus->value,
        ];

        match ($newStatus) {
            EscrowStatus::AWAITING_COMPLETION => $this->notifyAwaitingCompletion($escrow, $happening, $data),
            EscrowStatus::RELEASED => $this->notifyReleased($escrow, $happening, $data),
            EscrowStatus::REFUNDING => $this->notifyRefunding($escrow, $happening, $data),
            EscrowStatus::REFUNDED => $this->notifyRefunded($escrow, $happening, $data),
            default => null,
        };

        Log::info('Escrow status change notifications sent', [
            'escrow_uuid' => $escrow->uuid,
            'new_status' => $newStatus->value,
        ]);
    }

    private function notifyAwaitingCompletion($escrow, $happening, array $data): void
    {
        $ticketHolderIds = $escrow->tickets()
            ->where('status', TicketStatus::PAID)
            ->pluck('user_id')
            ->unique()
            ->toArray();

        if (! empty($ticketHolderIds)) {
            $this->notificationService->sendToMultipleUsers(
                $ticketHolderIds,
                'Event Completed',
                "The host has marked {$happening->title} as complete. Payout is being verified.",
                $data,
            );
        }
    }

    private function notifyReleased($escrow, $happening, array $data): void
    {
        $host = $escrow->host;

        if ($host) {
            $amount = number_format($escrow->host_payout_amount, 2);

            $this->notificationService->sendToUser(
                $host,
                "Payout Approved! \xF0\x9F\x92\xB0",
                "Your payout of \xE2\x82\xA6{$amount} for {$happening->title} has been approved.",
                $data,
            );
        }
    }

    private function notifyRefunding($escrow, $happening, array $data): void
    {

        $tickets = $escrow->tickets()
            ->whereIn('status', [TicketStatus::PAID, TicketStatus::REFUND_PROCESSING])
            ->with('user')
            ->get();

        foreach ($tickets as $ticket) {
            if ($ticket->user) {
                $amount = number_format($ticket->amount, 2);

                $this->notificationService->sendToUser(
                    $ticket->user,
                    'Refund Processing',
                    "A refund for {$happening->title} is being processed. You'll receive \xE2\x82\xA6{$amount} within 48 hours.",
                    $data,
                );
            }
        }


        $host = $escrow->host;

        if ($host) {
            $this->notificationService->sendToUser(
                $host,
                'Event Refund Initiated',
                "Refunds have been initiated for {$happening->title}.",
                $data,
            );
        }
    }

    private function notifyRefunded($escrow, $happening, array $data): void
    {
        $tickets = $escrow->tickets()
            ->where('status', TicketStatus::REFUNDED)
            ->with('user')
            ->get();

        foreach ($tickets as $ticket) {
            if ($ticket->user) {
                $amount = number_format($ticket->amount, 2);

                $this->notificationService->sendToUser(
                    $ticket->user,
                    "Refund Complete \xE2\x9C\x85",
                    "Your refund of \xE2\x82\xA6{$amount} for {$happening->title} has been completed.",
                    $data,
                );
            }
        }
    }
}
