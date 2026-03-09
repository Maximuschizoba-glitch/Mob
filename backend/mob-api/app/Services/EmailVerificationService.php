<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

class EmailVerificationService
{
    public function generateToken(User $user): string
    {
        $token = Str::random(64);

        Cache::put("email_verify:{$user->id}", $token, now()->addHours(24));

        return $token;
    }

    public function verifyToken(User $user, string $token): bool
    {
        $cachedToken = Cache::get("email_verify:{$user->id}");

        if ($cachedToken === null || $cachedToken !== $token) {
            return false;
        }

        Cache::forget("email_verify:{$user->id}");

        return true;
    }
}
