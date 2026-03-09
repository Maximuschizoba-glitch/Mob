<?php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Snap extends Model
{
    use HasUuid, SoftDeletes;

    protected $fillable = [
        'happening_id',
        'user_id',
        'media_url',
        'media_type',
        'thumbnail_url',
        'duration_seconds',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'expires_at' => 'datetime',
            'duration_seconds' => 'integer',
        ];
    }




    public function isVideo(): bool
    {
        return $this->media_type === 'video';
    }

    public function happening(): BelongsTo
    {
        return $this->belongsTo(Happening::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
