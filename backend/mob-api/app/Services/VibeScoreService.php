<?php

namespace App\Services;

use App\Enums\ActivityLevel;
use App\Enums\HappeningStatus;
use App\Models\Happening;

class VibeScoreService
{
    public function calculateVibeScore(Happening $happening): array
    {
        $now = now();
        $twoHoursAgo = $now->copy()->subHours(2);
        $oneHourAgo = $now->copy()->subHour();
        $thirtyMinAgo = $now->copy()->subMinutes(30);

        $recentSnaps = $happening->snaps()
            ->where('created_at', '>=', $twoHoursAgo)
            ->where('expires_at', '>', $now)
            ->select('id', 'user_id', 'created_at')
            ->get();

        $totalSnapCount = $recentSnaps->count();

        $uniqueSnappers = $recentSnaps->unique('user_id')->count();

        $weightedSnapCount = $recentSnaps->sum(function ($snap) use ($thirtyMinAgo, $oneHourAgo) {
            if ($snap->created_at >= $thirtyMinAgo) {
                return 3;
            }

            if ($snap->created_at >= $oneHourAgo) {
                return 2;
            }

            return 1;
        });

        $vibeScore = round($weightedSnapCount + ($uniqueSnappers * 0.5), 2);

        $activityLevel = match (true) {
            $totalSnapCount >= 8 => ActivityLevel::HIGH,
            $totalSnapCount >= 3 => ActivityLevel::MEDIUM,
            default => ActivityLevel::LOW,
        };

        return [
            'vibe_score' => $vibeScore,
            'activity_level' => $activityLevel,
        ];
    }

    public function updateHappeningVibe(Happening $happening): void
    {
        $result = $this->calculateVibeScore($happening);

        $happening->newQuery()
            ->where('id', $happening->id)
            ->update([
                'vibe_score' => $result['vibe_score'],
                'activity_level' => $result['activity_level'],
            ]);
    }

    public function recalculateAllActiveVibes(): int
    {
        $happenings = Happening::where('status', HappeningStatus::ACTIVE)
            ->where('expires_at', '>', now())
            ->get();

        foreach ($happenings as $happening) {
            $this->updateHappeningVibe($happening);
        }

        return $happenings->count();
    }
}
