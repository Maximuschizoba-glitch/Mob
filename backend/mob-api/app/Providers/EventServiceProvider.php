<?php

namespace App\Providers;

use App\Events\EscrowStatusChanged;
use App\Events\HappeningExpiringSoon;
use App\Events\HostVerificationUpdated;
use App\Events\SnapAdded;
use App\Events\TicketPurchased;
use App\Listeners\SendEscrowNotification;
use App\Listeners\SendHappeningExpiryNotification;
use App\Listeners\SendSnapNotification;
use App\Listeners\SendTicketPurchaseNotification;
use App\Listeners\SendVerificationNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

class EventServiceProvider extends ServiceProvider
{



    protected $listen = [
        TicketPurchased::class => [
            SendTicketPurchaseNotification::class,
        ],
        SnapAdded::class => [
            SendSnapNotification::class,
        ],
        EscrowStatusChanged::class => [
            SendEscrowNotification::class,
        ],
        HappeningExpiringSoon::class => [
            SendHappeningExpiryNotification::class,
        ],
        HostVerificationUpdated::class => [
            SendVerificationNotification::class,
        ],
    ];
}
