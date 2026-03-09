<?php

namespace App\Enums;

enum HappeningStatus: string
{
    case ACTIVE = 'active';
    case EXPIRED = 'expired';
    case HIDDEN = 'hidden';
    case REPORTED = 'reported';
    case COMPLETED = 'completed';
}
