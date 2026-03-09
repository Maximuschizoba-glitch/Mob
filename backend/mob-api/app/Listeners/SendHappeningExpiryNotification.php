<?php

namespace App\Listeners;

use App\Events\HappeningExpiringSoon;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class SendHappeningExpiryNotification implements ShouldQueue
{
    public function __construct(
        private NotificationService $notificationService,
    ) {}

    public function handle(HappeningExpiringSoon $event): void
    {
        $happening = $event->happening;
        $host = $happening->user;

        if (! $host) {
            return;
        }

        $data = [
            'type' => 'happening_expiring',
            'happening_uuid' => $happening->uuid,
        ];

        $this->notificationService->sendToUser(
            $host,
            "Happening Expiring Soon \xE2\x8F\xB0",
            "Your happening '{$happening->title}' expires in 1 hour.",
            $data,
        );

        Log::info('Happening expiry notification sent', [
            'happening_uuid' => $happening->uuid,
            'host_id' => $host->id,
        ]);
    }
}
