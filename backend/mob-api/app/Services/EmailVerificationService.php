<?php

namespace App\Services;

use App\Mail\EmailVerificationMail;
use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
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

    /**
     * Send verification email to the user.
     */
    public function sendVerificationEmail(User $user, string $token): void
    {
        try {
            Mail::to($user->email)->queue(new EmailVerificationMail($user, $token));
        } catch (\Throwable $e) {
            Log::error('Failed to send verification email', [
                'user_id' => $user->id,
                'email' => $user->email,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
