<?php

namespace App\Models;

use App\Enums\ActivityLevel;
use App\Enums\HappeningCategory;
use App\Enums\HappeningStatus;
use App\Enums\HappeningType;
use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Happening extends Model
{
    use HasUuid, SoftDeletes;

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'category',
        'type',
        'latitude',
        'longitude',
        'radius_meters',
        'address',
        'starts_at',
        'ends_at',
        'is_ticketed',
        'ticket_price',
        'ticket_quantity',
        'tickets_sold',
        'vibe_score',
        'activity_level',
        'status',
        'hidden_reason',
        'hidden_by',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'category' => HappeningCategory::class,
            'type' => HappeningType::class,
            'status' => HappeningStatus::class,
            'activity_level' => ActivityLevel::class,
            'latitude' => 'float',
            'longitude' => 'float',
            'ticket_price' => 'float',
            'vibe_score' => 'float',
            'is_ticketed' => 'boolean',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function snaps(): HasMany
    {
        return $this->hasMany(Snap::class);
    }

    public function tickets(): HasMany
    {
        return $this->hasMany(Ticket::class);
    }

    public function escrow(): HasOne
    {
        return $this->hasOne(Escrow::class);
    }

    public function reports(): HasMany
    {
        return $this->hasMany(Report::class);
    }

    public function hiddenByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'hidden_by');
    }

    public function isHidden(): bool
    {
        return in_array($this->status, [HappeningStatus::HIDDEN, HappeningStatus::REPORTED], true);
    }








    public function isHappeningNow(): bool
    {
        if ($this->status !== HappeningStatus::ACTIVE) {
            return false;
        }

        if ($this->expires_at !== null && $this->expires_at->isPast()) {
            return false;
        }


        return $this->starts_at === null || $this->starts_at->isPast();
    }




    public function isUpcoming(): bool
    {
        if ($this->status !== HappeningStatus::ACTIVE) {
            return false;
        }

        return $this->starts_at !== null && $this->starts_at->isFuture();
    }




    public function getDisplayStatus(): string
    {
        if (in_array($this->status, [HappeningStatus::HIDDEN, HappeningStatus::REPORTED], true)) {
            return 'hidden';
        }


        if ($this->status === HappeningStatus::COMPLETED) {
            return 'ended';
        }

        if ($this->status === HappeningStatus::EXPIRED
            || ($this->expires_at !== null && $this->expires_at->isPast())) {
            return 'expired';
        }

        if ($this->starts_at !== null && $this->starts_at->isFuture()) {
            return 'upcoming';
        }

        if ($this->status === HappeningStatus::ACTIVE) {
            return 'live';
        }

        return 'ended';
    }
}
