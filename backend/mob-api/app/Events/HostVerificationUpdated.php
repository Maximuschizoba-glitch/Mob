<?php

namespace App\Events;

use App\Enums\VerificationStatus;
use App\Models\HostProfile;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class HostVerificationUpdated
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public HostProfile $hostProfile,
        public VerificationStatus $newStatus,
    ) {}
}
