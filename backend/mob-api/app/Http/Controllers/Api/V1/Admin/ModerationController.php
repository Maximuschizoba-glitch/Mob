<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\EscrowStatus;
use App\Enums\HappeningStatus;
use App\Http\Controllers\Api\V1\BaseController;
use App\Http\Resources\HappeningResource;
use App\Models\Happening;
use App\Models\Report;
use App\Services\EscrowService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ModerationController extends BaseController
{
    public function __construct(
        private readonly EscrowService $escrowService,
    ) {}

    public function reportedHappenings(Request $request): JsonResponse
    {
        $status = $request->query('status');

        $query = Happening::query()
            ->has('reports')
            ->withCount('reports')
            ->with(['user', 'user.hostProfile', 'reports']);

        if ($status && HappeningStatus::tryFrom($status)) {
            $query->where('status', HappeningStatus::from($status));
        } else {
            $query->whereIn('status', [HappeningStatus::HIDDEN, HappeningStatus::REPORTED]);
        }

        $happenings = $query->orderByDesc('reports_count')
            ->paginate(20);

        $data = $happenings->through(function ($happening) {
            $resource = (new HappeningResource($happening))->toArray(request());
            $resource['reports_count'] = $happening->reports_count;
            $resource['report_reasons'] = $happening->reports->pluck('reason')
                ->map(fn ($reason) => $reason->value)
                ->unique()
                ->values()
                ->toArray();

            return $resource;
        });

        return response()->json([
            'success' => true,
            'message' => 'Reported happenings retrieved successfully',
            'data' => $data->items(),
            'meta' => [
                'current_page' => $data->currentPage(),
                'per_page' => $data->perPage(),
                'total' => $data->total(),
                'last_page' => $data->lastPage(),
            ],
        ]);
    }

    public function hideHappening(int $id): JsonResponse
    {
        $happening = Happening::find($id);

        if (! $happening) {
            return $this->errorResponse('Happening not found', null, 404);
        }

        if ($happening->status === HappeningStatus::HIDDEN) {
            return $this->errorResponse('Already hidden', null, 422);
        }

        $happening->update(['status' => HappeningStatus::HIDDEN]);

        $escrow = $happening->escrow;

        if ($escrow && in_array($escrow->status, [EscrowStatus::COLLECTING, EscrowStatus::HELD], true)) {
            $this->escrowService->initiateRefunds($escrow);
        }

        activity()
            ->performedOn($happening)
            ->causedBy(auth()->user())
            ->log('happening.hidden_by_admin');

        $happening->load(['user', 'user.hostProfile']);
        $happening->loadCount('snaps');

        return $this->successResponse(
            new HappeningResource($happening),
            'Happening hidden'
        );
    }

    public function reinstateHappening(int $id): JsonResponse
    {
        $happening = Happening::withTrashed()->find($id);

        if (! $happening) {
            return $this->errorResponse('Happening not found', null, 404);
        }

        $happening->update(['status' => HappeningStatus::ACTIVE]);

        if ($happening->trashed()) {
            $happening->restore();
        }

        Report::where('happening_id', $happening->id)
            ->update(['status' => 'reviewed']);

        activity()
            ->performedOn($happening)
            ->causedBy(auth()->user())
            ->log('happening.reinstated_by_admin');

        $happening->load(['user', 'user.hostProfile']);
        $happening->loadCount('snaps');

        return $this->successResponse(
            new HappeningResource($happening),
            'Happening reinstated'
        );
    }

    public function deleteHappening(int $id): JsonResponse
    {
        $happening = Happening::find($id);

        if (! $happening) {
            return $this->errorResponse('Happening not found', null, 404);
        }

        $escrow = $happening->escrow;

        if ($escrow && in_array($escrow->status, [EscrowStatus::COLLECTING, EscrowStatus::HELD], true)) {
            $this->escrowService->initiateRefunds($escrow);
        }

        $happening->delete();

        activity()
            ->performedOn($happening)
            ->causedBy(auth()->user())
            ->log('happening.deleted_by_admin');

        return $this->successResponse(null, 'Happening deleted');
    }
}
