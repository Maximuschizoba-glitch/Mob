<?php

namespace App\Listeners;

use App\Events\TicketPurchased;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class SendTicketPurchaseNotification implements ShouldQueue
{
    public function __construct(
        private NotificationService $notificationService,
    ) {}

    public function handle(TicketPurchased $event): void
    {
        $ticket = $event->ticket;
        $happening = $event->happening;

        $data = [
            'type' => 'ticket_purchased',
            'happening_uuid' => $happening->uuid,
            'ticket_uuid' => $ticket->uuid,
        ];


        $buyer = $ticket->user;
        if ($buyer) {
            $this->notificationService->sendToUser(
                $buyer,
                "Ticket Confirmed! \xF0\x9F\x8E\x89",
                "Your ticket for {$happening->title} is secured. Funds are held safely until the event is confirmed.",
                $data,
            );
        }


        $host = $happening->user;
        if ($host) {
            $happening->refresh();

            $this->notificationService->sendToUser(
                $host,
                'New Ticket Sold!',
                "Someone just bought a ticket to {$happening->title}. Total sold: {$happening->tickets_sold}",
                $data,
            );
        }

        Log::info('Ticket purchase notifications sent', [
            'ticket_uuid' => $ticket->uuid,
            'happening_uuid' => $happening->uuid,
        ]);
    }
}
