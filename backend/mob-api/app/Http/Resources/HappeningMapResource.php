<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HappeningMapResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $coverSnap = $this->relationLoaded('snaps')
            ? $this->snaps->first()
            : null;

        return [
            'uuid' => $this->uuid,
            'title' => $this->title,
            'category' => $this->category?->value,
            'type' => $this->type?->value,
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'activity_level' => $this->activity_level?->value,
            'vibe_score' => (float) $this->vibe_score,
            'snaps_count' => (int) ($this->snaps_count ?? 0),
            'is_ticketed' => (bool) $this->is_ticketed,
            'ticket_price' => $this->ticket_price !== null ? (float) $this->ticket_price : null,
            'cover_image_url' => $coverSnap?->media_url,
            'status' => $this->status?->value,
            'expires_at' => $this->expires_at?->toIso8601String(),
        ];
    }
}
