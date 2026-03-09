<?php

namespace App\Events;

use App\Models\Happening;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class HappeningExpiringSoon
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public Happening $happening,
    ) {}
}
