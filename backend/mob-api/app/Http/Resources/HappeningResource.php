<?php

namespace App\Http\Resources;

use App\Enums\HappeningStatus;
use App\Enums\VerificationStatus;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

class HappeningResource extends JsonResource
{
    public function toArray(Request $request): array
    {

        $coverSnap = $this->relationLoaded('snaps')
            ? $this->snaps->first()
            : null;

        return [
            'uuid' => $this->uuid,
            'title' => $this->title,
            'description' => $this->description,
            'category' => $this->category?->value,
            'type' => $this->type?->value,
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'radius_meters' => $this->radius_meters ? (int) $this->radius_meters : null,
            'address' => $this->address,
            'starts_at' => $this->starts_at?->toIso8601String(),
            'ends_at' => $this->ends_at?->toIso8601String(),
            'is_ticketed' => (bool) $this->is_ticketed,
            'ticket_price' => $this->ticket_price !== null ? (float) $this->ticket_price : null,
            'ticket_quantity' => $this->ticket_quantity !== null ? (int) $this->ticket_quantity : null,
            'tickets_sold' => (int) $this->tickets_sold,
            'tickets_remaining' => $this->is_ticketed && $this->ticket_quantity !== null
                ? (int) ($this->ticket_quantity - $this->tickets_sold)
                : null,
            'vibe_score' => (float) $this->vibe_score,
            'activity_level' => $this->activity_level?->value,
            'status' => $this->status?->value,
            'display_status' => $this->resource->getDisplayStatus(),
            'is_happening_now' => $this->resource->isHappeningNow(),
            'expires_at' => $this->expires_at?->toIso8601String(),
            'time_remaining' => $this->formatTimeRemaining(),
            'distance_km' => isset($this->resource->distance_km)
                ? (float) $this->resource->distance_km
                : null,
            'snaps_count' => (int) ($this->snaps_count ?? 0),
            'has_snaps' => ($this->snaps_count ?? 0) > 0,
            'cover_image_url' => $coverSnap?->media_url,
            'host' => $this->whenLoaded('user', function () {
                $user = $this->user;
                $hostProfile = $this->whenLoaded('user.hostProfile', fn () => $user->hostProfile, null);

                return [
                    'uuid' => $user->uuid,
                    'name' => $user->name,
                    'avatar_url' => $user->avatar_url,
                    'is_verified' => $user->relationLoaded('hostProfile')
                        && $user->hostProfile !== null
                        && $user->hostProfile->verification_status === VerificationStatus::APPROVED,
                    'host_type' => $user->relationLoaded('hostProfile') && $user->hostProfile
                        ? $user->hostProfile->host_type?->value
                        : null,
                ];
            }),
            'is_active' => $this->status === HappeningStatus::ACTIVE
                && (! $this->expires_at || $this->expires_at->isFuture()),
            'can_buy_tickets' => $this->status === HappeningStatus::ACTIVE
                && $this->is_ticketed
                && (! $this->expires_at || $this->expires_at->isFuture())
                && ($this->ticket_quantity === null || $this->tickets_sold < $this->ticket_quantity),
            'can_add_snaps' => $this->status === HappeningStatus::ACTIVE
                && (! $this->expires_at || $this->expires_at->isFuture()),
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
