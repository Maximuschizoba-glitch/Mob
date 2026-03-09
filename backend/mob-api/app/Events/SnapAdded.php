<?php

namespace App\Events;

use App\Models\Happening;
use App\Models\Snap;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class SnapAdded
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public Snap $snap,
        public Happening $happening,
    ) {}
}
