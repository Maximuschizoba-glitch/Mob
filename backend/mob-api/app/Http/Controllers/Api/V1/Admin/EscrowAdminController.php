<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\EscrowStatus;
use App\Http\Controllers\Api\V1\BaseController;
use App\Http\Resources\EscrowEventLogResource;
use App\Http\Resources\EscrowResource;
use App\Http\Resources\TicketResource;
use App\Models\Escrow;
use App\Services\EscrowService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EscrowAdminController extends BaseController
{
    public function __construct(
        private readonly EscrowService $escrowService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = Escrow::query();

        $status = $request->query('status');

        if ($status && EscrowStatus::tryFrom($status)) {
            $query->where('status', EscrowStatus::from($status));
        }

        $escrows = $query->with(['happening', 'host'])
            ->orderByDesc('created_at')
            ->paginate(20);

        return $this->paginatedResponse($escrows, EscrowResource::class, 'Escrows retrieved successfully');
    }

    public function show(int $id): JsonResponse
    {
        $escrow = Escrow::find($id);

        if (! $escrow) {
            return $this->errorResponse('Escrow not found', null, 404);
        }

        $escrow->load(['happening', 'host', 'tickets.user', 'escrowEventLogs.performer']);

        return $this->successResponse([
            'escrow' => new EscrowResource($escrow),
            'tickets' => TicketResource::collection($escrow->tickets),
            'event_log' => EscrowEventLogResource::collection($escrow->escrowEventLogs),
        ], 'Escrow retrieved successfully');
    }

    public function approve(int $id): JsonResponse
    {
        $escrow = Escrow::find($id);

        if (! $escrow) {
            return $this->errorResponse('Escrow not found', null, 404);
        }

        if ($escrow->status !== EscrowStatus::AWAITING_COMPLETION) {
            return $this->errorResponse('Escrow is not awaiting approval', null, 422);
        }

        $this->escrowService->adminApprove($escrow, auth()->user());

        activity()
            ->performedOn($escrow)
            ->causedBy(auth()->user())
            ->withProperties([
                'total_amount' => $escrow->total_amount,
                'host_payout' => $escrow->host_payout_amount,
            ])
            ->log('escrow.approved_by_admin');

        return $this->successResponse(
            new EscrowResource($escrow->fresh(['happening', 'host'])),
            'Escrow approved. Host payout has been queued.'
        );
    }

    public function reject(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'reason' => ['required', 'string', 'max:1000'],
        ]);

        $escrow = Escrow::find($id);

        if (! $escrow) {
            return $this->errorResponse('Escrow not found', null, 404);
        }

        if ($escrow->status !== EscrowStatus::AWAITING_COMPLETION) {
            return $this->errorResponse('Escrow is not awaiting approval', null, 422);
        }

        $this->escrowService->adminReject($escrow, auth()->user(), $request->input('reason'));
        $this->escrowService->initiateRefunds($escrow);

        activity()
            ->performedOn($escrow)
            ->causedBy(auth()->user())
            ->withProperties(['reason' => $request->input('reason')])
            ->log('escrow.rejected_by_admin');

        return $this->successResponse(
            new EscrowResource($escrow->fresh(['happening', 'host'])),
            'Escrow rejected. Refunds have been initiated.'
        );
    }

    public function forceRefund(int $id): JsonResponse
    {
        $escrow = Escrow::find($id);

        if (! $escrow) {
            return $this->errorResponse('Escrow not found', null, 404);
        }

        if (in_array($escrow->status, [EscrowStatus::RELEASED, EscrowStatus::REFUNDED], true)) {
            return $this->errorResponse('Cannot refund — escrow is already finalized', null, 422);
        }

        $this->escrowService->initiateRefunds($escrow);

        activity()
            ->performedOn($escrow)
            ->causedBy(auth()->user())
            ->withProperties(['reason' => 'Admin force refund'])
            ->log('escrow.force_refund_by_admin');

        return $this->successResponse(
            new EscrowResource($escrow->fresh(['happening', 'host'])),
            'Force refund initiated for all ticket holders.'
        );
    }
}
