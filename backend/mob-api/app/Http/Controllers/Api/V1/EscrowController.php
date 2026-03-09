<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\UserRole;
use App\Http\Resources\EscrowEventLogResource;
use App\Http\Resources\EscrowResource;
use App\Http\Resources\TicketResource;
use App\Models\Escrow;
use App\Models\Happening;
use App\Models\Ticket;
use App\Services\EscrowService;
use Illuminate\Http\JsonResponse;

class EscrowController extends BaseController
{
    public function __construct(
        private readonly EscrowService $escrowService,
    ) {}

    public function show(string $uuid): JsonResponse
    {
        $escrow = Escrow::where('uuid', $uuid)->first();

        if (! $escrow) {
            return $this->errorResponse('Escrow not found', null, 404);
        }

        $user = auth()->user();


        if ($user->role === UserRole::ADMIN) {
            $escrow->load(['happening', 'host', 'tickets.user', 'escrowEventLogs.performer']);

            return $this->successResponse([
                'escrow' => new EscrowResource($escrow),
                'tickets' => TicketResource::collection($escrow->tickets),
                'event_log' => EscrowEventLogResource::collection($escrow->escrowEventLogs),
            ], 'Escrow retrieved successfully');
        }


        if ($user->id === $escrow->host_id) {
            $escrow->load(['happening', 'tickets.user', 'escrowEventLogs']);

            return $this->successResponse([
                'escrow' => new EscrowResource($escrow),
                'tickets' => TicketResource::collection($escrow->tickets),
                'event_log' => EscrowEventLogResource::collection($escrow->escrowEventLogs),
            ], 'Escrow retrieved successfully');
        }


        $buyerTickets = Ticket::where('escrow_id', $escrow->id)
            ->where('user_id', $user->id)
            ->with('happening')
            ->get();

        if ($buyerTickets->isNotEmpty()) {
            $statusMessage = $this->getEscrowStatusMessage($escrow->status->value);

            return $this->successResponse([
                'escrow_status' => $escrow->status->value,
                'escrow_status_message' => $statusMessage,
                'tickets' => TicketResource::collection($buyerTickets),
            ], 'Escrow retrieved successfully');
        }

        return $this->errorResponse('You do not have access to this escrow', null, 403);
    }




    public function showByHappening(string $happeningUuid): JsonResponse
    {
        $happening = Happening::where('uuid', $happeningUuid)->first();

        if (! $happening) {
            return $this->errorResponse('Happening not found', null, 404);
        }

        $escrow = Escrow::where('happening_id', $happening->id)->first();

        if (! $escrow) {
            return $this->errorResponse('No escrow found for this happening', null, 404);
        }

        return $this->show($escrow->uuid);
    }

    public function hostMarkComplete(string $uuid): JsonResponse
    {
        $escrow = Escrow::where('uuid', $uuid)->first();

        if (! $escrow) {
            return $this->errorResponse('Escrow not found', null, 404);
        }

        $user = auth()->user();

        if ($user->id !== $escrow->host_id) {
            return $this->errorResponse('Only the event host can mark completion', null, 403);
        }

        try {
            $this->escrowService->markHostComplete($escrow, $user);
        } catch (\LogicException $e) {
            return $this->errorResponse($e->getMessage(), null, 422);
        } catch (\InvalidArgumentException $e) {
            return $this->errorResponse($e->getMessage(), null, 422);
        }



        $happening = $escrow->happening;
        $happening->status = \App\Enums\HappeningStatus::COMPLETED;
        $happening->expires_at = now();
        $happening->save();

        $escrow->load(['happening', 'host', 'tickets', 'escrowEventLogs']);

        return $this->successResponse(
            new EscrowResource($escrow),
            'Event marked as complete. Awaiting admin approval.'
        );
    }

    private function getEscrowStatusMessage(string $status): string
    {
        return match ($status) {
            'collecting' => 'Your payment is secured. Funds are held until the event is confirmed.',
            'held' => 'The event is happening now. Your funds are held securely.',
            'awaiting_completion' => 'The event has ended. Payout is being verified.',
            'released' => 'Event confirmed! The host has been paid.',
            'refunding' => "A refund is being processed. You'll receive your money within 48 hours.",
            'refunded' => 'Your refund has been completed.',
            'disputed' => 'This transaction is under review.',
            default => 'Status unknown.',
        };
    }
}
