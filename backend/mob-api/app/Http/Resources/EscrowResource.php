<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EscrowResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'status' => $this->status?->value,
            'total_amount' => (float) $this->total_amount,
            'platform_fee' => (float) $this->platform_fee,
            'host_payout_amount' => (float) $this->host_payout_amount,
            'tickets_count' => (int) $this->tickets_count,
            'host_completed_at' => $this->host_completed_at?->toIso8601String(),
            'admin_approved_at' => $this->admin_approved_at?->toIso8601String(),
            'released_at' => $this->released_at?->toIso8601String(),
            'refund_initiated_at' => $this->refund_initiated_at?->toIso8601String(),
            'refund_completed_at' => $this->refund_completed_at?->toIso8601String(),
            'happening' => $this->whenLoaded('happening', function () {
                return [
                    'uuid' => $this->happening->uuid,
                    'title' => $this->happening->title,
                    'starts_at' => $this->happening->starts_at?->toIso8601String(),
                    'address' => $this->happening->address,
                ];
            }),
            'host' => $this->whenLoaded('host', function () {
                return [
                    'uuid' => $this->host->uuid,
                    'name' => $this->host->name,
                ];
            }),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
