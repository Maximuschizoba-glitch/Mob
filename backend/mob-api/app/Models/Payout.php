<?php

namespace App\Models;

use App\Enums\PaymentGateway;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payout extends Model
{
    protected $fillable = [
        'host_id',
        'happening_id',
        'escrow_id',
        'amount',
        'platform_fee',
        'status',
        'payout_reference',
        'payout_gateway',
        'processed_at',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'float',
            'platform_fee' => 'float',
            'payout_gateway' => PaymentGateway::class,
            'processed_at' => 'datetime',
        ];
    }

    public function host(): BelongsTo
    {
        return $this->belongsTo(User::class, 'host_id');
    }

    public function happening(): BelongsTo
    {
        return $this->belongsTo(Happening::class);
    }

    public function escrow(): BelongsTo
    {
        return $this->belongsTo(Escrow::class);
    }
}
