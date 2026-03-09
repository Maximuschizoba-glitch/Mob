<?php

namespace App\Enums;

enum PaymentGateway: string
{
    case PAYSTACK = 'paystack';
    case FLUTTERWAVE = 'flutterwave';
}
