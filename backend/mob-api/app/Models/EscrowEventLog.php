<?php

namespace App\Models;

use App\Enums\EscrowAction;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EscrowEventLog extends Model
{
    protected $table = 'escrow_events_log';

    protected $fillable = [
        'escrow_id',
        'action',
        'performed_by_user_id',
        'performed_by_role',
        'metadata',
    ];

    protected function casts(): array
    {
        return [
            'action' => EscrowAction::class,
            'metadata' => 'array',
        ];
    }

    public function escrow(): BelongsTo
    {
        return $this->belongsTo(Escrow::class);
    }

    public function performer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'performed_by_user_id');
    }
}
