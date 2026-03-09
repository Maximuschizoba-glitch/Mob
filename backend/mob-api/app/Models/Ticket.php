<?php

namespace App\Models;

use App\Enums\PaymentGateway;
use App\Enums\TicketStatus;
use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Ticket extends Model
{
    use HasUuid;

    protected $fillable = [
        'happening_id',
        'escrow_id',
        'user_id',
        'quantity',
        'ticket_number',
        'payment_reference',
        'payment_gateway',
        'amount',
        'currency',
        'status',
        'escrow_status_snapshot',
        'paid_at',
        'refunded_at',
        'checked_in_at',
    ];

    protected function casts(): array
    {
        return [
            'status' => TicketStatus::class,
            'payment_gateway' => PaymentGateway::class,
            'amount' => 'float',
            'paid_at' => 'datetime',
            'refunded_at' => 'datetime',
            'checked_in_at' => 'datetime',
        ];
    }

    public function happening(): BelongsTo
    {
        return $this->belongsTo(Happening::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function escrow(): BelongsTo
    {
        return $this->belongsTo(Escrow::class);
    }
}
