<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EscrowEventLogResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'action' => $this->action?->value,
            'performed_by_role' => $this->performed_by_role,
            'performed_by' => $this->whenLoaded('performer', function () {
                return [
                    'uuid' => $this->performer->uuid,
                    'name' => $this->performer->name,
                ];
            }),
            'metadata' => $this->metadata,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
