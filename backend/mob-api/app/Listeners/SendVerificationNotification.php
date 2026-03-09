<?php

namespace App\Listeners;

use App\Enums\VerificationStatus;
use App\Events\HostVerificationUpdated;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class SendVerificationNotification implements ShouldQueue
{
    public function __construct(
        private NotificationService $notificationService,
    ) {}

    public function handle(HostVerificationUpdated $event): void
    {
        $hostProfile = $event->hostProfile;
        $newStatus = $event->newStatus;
        $user = $hostProfile->user;

        if (! $user) {
            return;
        }

        $data = [
            'type' => 'verification_updated',
            'status' => $newStatus->value,
        ];

        match ($newStatus) {
            VerificationStatus::APPROVED => $this->notificationService->sendToUser(
                $user,
                "Verified! \xE2\x9C\x85",
                'Your host verification has been approved. You now have a verified badge.',
                $data,
            ),
            VerificationStatus::REJECTED => $this->notificationService->sendToUser(
                $user,
                'Verification Update',
                'Your host verification was not approved. You can re-submit with updated information.',
                $data,
            ),
            default => null,
        };

        Log::info('Verification notification sent', [
            'host_profile_id' => $hostProfile->id,
            'user_id' => $user->id,
            'status' => $newStatus->value,
        ]);
    }
}
