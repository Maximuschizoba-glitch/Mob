<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\EscrowStatus;
use App\Enums\HappeningStatus;
use App\Http\Requests\Report\CreateReportRequest;
use App\Http\Resources\ReportResource;
use App\Models\Happening;
use App\Models\Report;
use App\Services\EscrowService;
use Illuminate\Http\JsonResponse;

class ReportController extends BaseController
{
    public function __construct(
        private readonly EscrowService $escrowService,
    ) {}

    public function store(CreateReportRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $happening = Happening::where('uuid', $validated['happening_uuid'])->first();

        if (! $happening) {
            return $this->errorResponse('Happening not found', null, 404);
        }

        if ($happening->status === HappeningStatus::HIDDEN) {
            return $this->errorResponse('This happening is already hidden', null, 422);
        }

        $user = $request->user();

        $alreadyReported = Report::where('happening_id', $happening->id)
            ->where('user_id', $user->id)
            ->exists();

        if ($alreadyReported) {
            return $this->errorResponse('You have already reported this happening', null, 422);
        }

        $report = Report::create([
            'happening_id' => $happening->id,
            'user_id' => $user->id,
            'reason' => $validated['reason'],
            'details' => $validated['details'] ?? null,
            'status' => 'pending',
        ]);

        $reportCount = Report::where('happening_id', $happening->id)->count();

        if ($reportCount >= config('mob.reports_to_auto_hide', 3)) {
            $happening->status = HappeningStatus::HIDDEN;
            $happening->save();

            $escrow = $happening->escrow;

            if ($escrow && in_array($escrow->status, [EscrowStatus::COLLECTING, EscrowStatus::HELD], true)) {
                $this->escrowService->initiateRefunds($escrow);
            }

            activity()
                ->performedOn($happening)
                ->causedBy(null)
                ->withProperties(['reason' => 'Auto-hidden due to ' . $reportCount . ' reports'])
                ->log('happening.auto_hidden');
        }

        $report->load(['happening', 'user']);

        return $this->successResponse(
            new ReportResource($report),
            'Report submitted successfully',
            201
        );
    }
}
