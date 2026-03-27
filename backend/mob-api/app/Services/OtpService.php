<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OtpService
{
    public function generateOtp(string $phone): string
    {
        if (config('otp.bypass_enabled')) {
            $otp = config('otp.bypass_code', '123456');
            Cache::put("otp:{$phone}", $otp, now()->addMinutes(10));

            return $otp;
        }

        $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        Cache::put("otp:{$phone}", $otp, now()->addMinutes(10));

        return $otp;
    }

    public function verifyOtp(string $phone, string $otp): bool
    {
        if (config('otp.bypass_enabled') && $otp === config('otp.bypass_code', '123456')) {
            Cache::forget("otp:{$phone}");

            return true;
        }

        $cachedOtp = Cache::get("otp:{$phone}");

        if ($cachedOtp === null || $cachedOtp !== $otp) {
            return false;
        }

        Cache::forget("otp:{$phone}");

        return true;
    }

    /**
     * Send OTP via Termii SMS gateway.
     */
    public function sendViaSms(string $phone, string $otp): void
    {
        $apiKey = config('services.termii.api_key');

        if (! $apiKey) {
            Log::warning('Termii API key not configured — OTP not sent', ['phone' => $phone]);

            return;
        }

        $response = Http::post('https://v3.api.termii.com/api/sms/send', [
            'to' => $phone,
            'from' => config('services.termii.sender_id', 'Mob'),
            'sms' => "Your Mob verification code is: {$otp}. Valid for 10 minutes.",
            'type' => 'plain',
            'channel' => 'dnd',
            'api_key' => $apiKey,
        ]);

        if (! $response->successful()) {
            Log::error('Termii SMS failed', [
                'phone' => $phone,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
        }
    }
}
