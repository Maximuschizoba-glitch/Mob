<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'avatar_url' => $this->avatar_url,
            'role' => $this->role,
            'is_guest' => $this->is_guest,
            'email_verified' => $this->email_verified_at !== null,
            'phone_verified' => $this->phone_verified_at !== null,
            'has_host_profile' => $this->relationLoaded('hostProfile') && $this->hostProfile !== null,
            'host_verification_status' => $this->relationLoaded('hostProfile') && $this->hostProfile
                ? $this->hostProfile->verification_status
                : null,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
