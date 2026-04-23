<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Rate Limiting Configuration
    |--------------------------------------------------------------------------
    |
    | Override any limit via .env. In non-production environments the
    | AppServiceProvider falls back to higher defaults automatically, so
    | you only need these keys if you want to override the defaults.
    |
    | Example .env overrides:
    |   RATELIMIT_API_AUTH=300
    |   RATELIMIT_API_GUEST=60
    |   RATELIMIT_AUTH=20
    |   RATELIMIT_WEBHOOKS=200
    |   RATELIMIT_POSTING=30
    |
    */

    'api_auth'  => env('RATELIMIT_API_AUTH'),
    'api_guest' => env('RATELIMIT_API_GUEST'),
    'auth'      => env('RATELIMIT_AUTH'),
    'webhooks'  => env('RATELIMIT_WEBHOOKS'),
    'posting'   => env('RATELIMIT_POSTING'),

];
