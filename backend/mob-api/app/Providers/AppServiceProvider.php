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
        // All limits are configurable via .env — defaults are generous in non-prod, strict in prod.
        $isProd = $this->app->environment('production');

        RateLimiter::for('api', function (Request $request) use ($isProd) {
            $authLimit  = (int) config('ratelimit.api_auth',  $isProd ? 120 : 600);
            $guestLimit = (int) config('ratelimit.api_guest', $isProd ? 30  : 120);

            return $request->user()
                ? Limit::perMinute($authLimit)->by($request->user()->id)
                : Limit::perMinute($guestLimit)->by($request->ip());
        });

        RateLimiter::for('auth', function (Request $request) use ($isProd) {
            $limit = (int) config('ratelimit.auth', $isProd ? 10 : 60);

            return Limit::perMinute($limit)->by($request->ip());
        });

        RateLimiter::for('webhooks', function (Request $request) {
            $limit = (int) config('ratelimit.webhooks', 100);

            return Limit::perMinute($limit)->by($request->ip());
        });

        RateLimiter::for('posting', function (Request $request) use ($isProd) {
            $limit = (int) config('ratelimit.posting', $isProd ? 20 : 60);

            return Limit::perMinute($limit)->by($request->user()?->id ?: $request->ip());
        });
    }
}
