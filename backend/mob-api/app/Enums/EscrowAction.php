<?php

namespace App\Enums;

enum EscrowAction: string
{
    case CREATED = 'created';
    case TICKET_ADDED = 'ticket_added';
    case TICKET_REFUNDED = 'ticket_refunded';
    case HOST_MARKED_COMPLETE = 'host_marked_complete';
    case ADMIN_APPROVED = 'admin_approved';
    case ADMIN_REJECTED = 'admin_rejected';
    case FUNDS_RELEASED = 'funds_released';
    case REFUND_INITIATED = 'refund_initiated';
    case REFUND_COMPLETED = 'refund_completed';
    case ADMIN_OVERRIDE = 'admin_override';
    case EVENT_STARTED = 'event_started';
}
