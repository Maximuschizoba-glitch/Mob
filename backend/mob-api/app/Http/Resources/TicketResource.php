<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TicketResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'ticket_number' => $this->ticket_number,
            'payment_reference' => $this->payment_reference,
            'amount' => (float) $this->amount,
            'currency' => $this->currency,
            'status' => $this->status?->value,
            'payment_gateway' => $this->payment_gateway?->value,
            'paid_at' => $this->paid_at?->toIso8601String(),
            'refunded_at' => $this->refunded_at?->toIso8601String(),
            'escrow_status' => $this->resolveEscrowStatus(),
            'escrow_status_message' => $this->resolveEscrowStatusMessage(),
            'happening' => $this->whenLoaded('happening', function () {
                return [
                    'uuid' => $this->happening->uuid,
                    'title' => $this->happening->title,
                    'starts_at' => $this->happening->starts_at?->toIso8601String(),
                    'address' => $this->happening->address,
                ];
            }),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }

    private function resolveEscrowStatus(): ?string
    {
        if ($this->relationLoaded('escrow') && $this->escrow) {
            return $this->escrow->status->value;
        }

        return $this->escrow_status_snapshot;
    }

    private function resolveEscrowStatusMessage(): ?string
    {
        $status = $this->resolveEscrowStatus();

        if ($status === null) {
            return null;
        }

        return match ($status) {
            'collecting' => 'Your payment is secured. Funds are held until the event is confirmed.',
            'held' => 'The event is happening now. Your funds are held securely.',
            'awaiting_completion' => 'The event has ended. Payout is being verified.',
            'released' => 'Event confirmed! The host has been paid.',
            'refunding' => "A refund is being processed. You'll receive your money within 48 hours.",
            'refunded' => 'Your refund has been completed.',
            'disputed' => 'This transaction is under review.',
            default => null,
        };
    }
}
