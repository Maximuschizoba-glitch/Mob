<?php

namespace App\Enums;

enum ReportReason: string
{
    case FAKE = 'fake';
    case SCAM = 'scam';
    case MISLEADING = 'misleading';
    case WRONG_LOCATION = 'wrong_location';
}
