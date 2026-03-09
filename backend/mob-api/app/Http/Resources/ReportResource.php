<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReportResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'reason' => $this->reason?->value,
            'details' => $this->details,
            'status' => $this->status,
            'happening' => $this->whenLoaded('happening', function () {
                return [
                    'uuid' => $this->happening->uuid,
                    'title' => $this->happening->title,
                    'status' => $this->happening->status?->value,
                ];
            }),
            'reporter' => $this->whenLoaded('user', function () {
                return [
                    'uuid' => $this->user->uuid,
                    'name' => $this->user->name,
                ];
            }),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
