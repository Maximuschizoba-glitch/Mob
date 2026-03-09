<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SnapResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'media_url' => $this->media_url,
            'media_type' => $this->media_type,
            'thumbnail_url' => $this->thumbnail_url,
            'duration_seconds' => $this->duration_seconds,
            'is_video' => $this->isVideo(),
            'expires_at' => $this->expires_at?->toIso8601String(),
            'time_remaining' => $this->formatTimeRemaining(),
            'uploader' => $this->whenLoaded('user', function () {
                return [
                    'uuid' => $this->user->uuid,
                    'name' => $this->user->name,
                    'avatar_url' => $this->user->avatar_url,
                ];
            }),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }

    private function formatTimeRemaining(): string
    {
        if ($this->expires_at === null || $this->expires_at->isPast()) {
            return 'Expired';
        }

        $diff = now()->diff($this->expires_at);
        $hours = ($diff->d * 24) + $diff->h;
        $minutes = $diff->i;

        if ($hours > 0) {
            return "{$hours}h {$minutes}m left";
        }

        return "{$minutes}m left";
    }
}
