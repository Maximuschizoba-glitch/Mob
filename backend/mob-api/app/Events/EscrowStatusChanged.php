<?php

namespace App\Events;

use App\Enums\EscrowStatus;
use App\Models\Escrow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class EscrowStatusChanged
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public Escrow $escrow,
        public EscrowStatus $previousStatus,
        public EscrowStatus $newStatus,
    ) {}
}
