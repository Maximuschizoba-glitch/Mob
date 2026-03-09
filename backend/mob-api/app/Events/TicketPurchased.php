<?php

namespace App\Events;

use App\Models\Happening;
use App\Models\Ticket;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class TicketPurchased
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public Ticket $ticket,
        public Happening $happening,
    ) {}
}
