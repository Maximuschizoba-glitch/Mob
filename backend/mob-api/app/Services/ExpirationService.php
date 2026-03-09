<?php

namespace App\Services;

use App\Enums\HappeningStatus;
use App\Models\Happening;
use App\Models\Snap;

class ExpirationService
{
    public function expireHappenings(): int
    {
        $happenings = Happening::where('status', HappeningStatus::ACTIVE)
            ->where('expires_at', '<', now())
            ->get();

        $count = $happenings->count();

        foreach ($happenings as $happening) {
            $happening->update(['status' => HappeningStatus::EXPIRED]);
            $happening->delete();
        }

        return $count;
    }

    public function expireSnaps(): int
    {
        $snaps = Snap::where('expires_at', '<', now())
            ->whereNull('deleted_at')
            ->get();

        $count = $snaps->count();

        foreach ($snaps as $snap) {
            $snap->delete();
        }

        return $count;
    }
}
