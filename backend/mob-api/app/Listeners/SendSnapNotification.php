<?php

namespace App\Listeners;

use App\Events\SnapAdded;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class SendSnapNotification implements ShouldQueue
{
    public function __construct(
        private NotificationService $notificationService,
    ) {}

    public function handle(SnapAdded $event): void
    {
        $snap = $event->snap;
        $happening = $event->happening;
        $host = $happening->user;


        if (! $host || $snap->user_id === $host->id) {
            return;
        }

        $snapper = $snap->user;
        $snapperName = $snapper ? $snapper->name : 'Someone';

        $data = [
            'type' => 'snap_added',
            'happening_uuid' => $happening->uuid,
        ];

        $this->notificationService->sendToUser(
            $host,
            "New Snap! \xF0\x9F\x93\xB8",
            "{$snapperName} just snapped at {$happening->title}",
            $data,
        );

        Log::info('Snap notification sent to host', [
            'snap_uuid' => $snap->uuid,
            'happening_uuid' => $happening->uuid,
            'host_id' => $host->id,
        ]);
    }
}
