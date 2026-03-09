<?php

namespace App\Enums;

enum TicketStatus: string
{
    case PENDING = 'pending';
    case PAID = 'paid';
    case REFUND_PROCESSING = 'refund_processing';
    case REFUNDED = 'refunded';
}
