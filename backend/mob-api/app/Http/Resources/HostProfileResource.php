<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HostProfileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'host_type' => $this->host_type?->value,
            'business_name' => $this->business_name,
            'bio' => $this->bio,
            'verification_status' => $this->verification_status?->value,
            'verification_document_type' => $this->verification_document_type,
            'verified_at' => $this->verified_at?->toIso8601String(),
            'user' => $this->whenLoaded('user', function () {
                return [
                    'uuid' => $this->user->uuid,
                    'name' => $this->user->name,
                    'email' => $this->user->email,
                    'phone' => $this->user->phone,
                ];
            }),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
