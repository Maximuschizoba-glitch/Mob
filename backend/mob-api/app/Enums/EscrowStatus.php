<?php

namespace App\Enums;

enum EscrowStatus: string
{
    case COLLECTING = 'collecting';
    case HELD = 'held';
    case AWAITING_COMPLETION = 'awaiting_completion';
    case RELEASED = 'released';
    case REFUNDING = 'refunding';
    case REFUNDED = 'refunded';
    case DISPUTED = 'disputed';
}
