<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{



    public function register(): void
    {

    }




    public function boot(): void
    {
        $this->ensureOtpBypassDisabledInProduction();
        $this->configureRateLimiting();
    }




    protected function ensureOtpBypassDisabledInProduction(): void
    {
        if ($this->app->environment('production') && config('otp.bypass_enabled')) {
            Log::critical(
                'OTP bypass is ENABLED in production! '
                . 'Set OTP_BYPASS_ENABLED=false in .env before public launch.'
            );
        }
    }

    protected function configureRateLimiting(): void
    {

        RateLimiter::for('api', function (Request $request) {
            return $request->user()
                ? Limit::perMinute(120)->by($request->user()->id)
                : Limit::perMinute(30)->by($request->ip());
        });


        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(10)->by($request->ip());
        });


        RateLimiter::for('webhooks', function (Request $request) {
            return Limit::perMinute(100)->by($request->ip());
        });


        RateLimiter::for('posting', function (Request $request) {
            return Limit::perMinute(20)->by($request->user()?->id ?: $request->ip());
        });
    }
}
