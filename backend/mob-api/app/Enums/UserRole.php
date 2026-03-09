<?php

namespace App\Enums;

enum UserRole: string
{
    case GUEST = 'guest';
    case USER = 'user';
    case HOST = 'host';
    case MODERATOR = 'moderator';
    case ADMIN = 'admin';
}
