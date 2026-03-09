<?php

namespace App\Models;

use App\Enums\HostType;
use App\Enums\VerificationStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HostProfile extends Model
{
    protected $fillable = [
        'user_id',
        'host_type',
        'business_name',
        'bio',
        'verification_status',
        'verification_document_url',
        'verification_document_type',
        'verified_at',
        'admin_notes',
        'reviewed_by',
        'reviewed_at',
        'rejection_reason',
    ];

    protected function casts(): array
    {
        return [
            'host_type' => HostType::class,
            'verification_status' => VerificationStatus::class,
            'verified_at' => 'datetime',
            'reviewed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    public function isPending(): bool
    {
        return $this->verification_status === VerificationStatus::PENDING;
    }

    public function isApproved(): bool
    {
        return $this->verification_status === VerificationStatus::APPROVED;
    }

    public function isRejected(): bool
    {
        return $this->verification_status === VerificationStatus::REJECTED;
    }
}
