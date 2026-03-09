<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

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
}
