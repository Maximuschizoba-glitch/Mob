<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Schedule::command('content:expire')->hourly();
Schedule::command('happenings:update-vibes')->everyFifteenMinutes();
Schedule::command('escrows:transition-held')->everyFiveMinutes();
Schedule::command('escrows:check-refunds')->everyThirtyMinutes();
Schedule::command('happenings:notify-expiring')->everyThirtyMinutes();
