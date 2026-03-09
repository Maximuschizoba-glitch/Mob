<?php

namespace App\Models;

use App\Enums\EscrowStatus;
use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Escrow extends Model
{
    use HasUuid;

    protected $fillable = [
        'happening_id',
        'host_id',
        'total_amount',
        'platform_fee',
        'host_payout_amount',
        'tickets_count',
        'status',
        'host_completed_at',
        'admin_approved_at',
        'released_at',
        'refund_initiated_at',
        'refund_completed_at',
        'admin_notes',
    ];

    protected function casts(): array
    {
        return [
            'status' => EscrowStatus::class,
            'total_amount' => 'float',
            'platform_fee' => 'float',
            'host_payout_amount' => 'float',
            'host_completed_at' => 'datetime',
            'admin_approved_at' => 'datetime',
            'released_at' => 'datetime',
            'refund_initiated_at' => 'datetime',
            'refund_completed_at' => 'datetime',
        ];
    }

    public function happening(): BelongsTo
    {
        return $this->belongsTo(Happening::class);
    }

    public function host(): BelongsTo
    {
        return $this->belongsTo(User::class, 'host_id');
    }

    public function tickets(): HasMany
    {
        return $this->hasMany(Ticket::class);
    }

    public function escrowEventLogs(): HasMany
    {
        return $this->hasMany(EscrowEventLog::class);
    }

    public function payout(): HasOne
    {
        return $this->hasOne(Payout::class);
    }
}
