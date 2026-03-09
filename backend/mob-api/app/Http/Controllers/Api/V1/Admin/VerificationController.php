<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\HostType;
use App\Enums\VerificationStatus;
use App\Events\HostVerificationUpdated;
use App\Http\Controllers\Api\V1\BaseController;
use App\Http\Resources\AdminHostProfileResource;
use App\Models\HostProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VerificationController extends BaseController
{
    public function index(Request $request): JsonResponse
    {
        $status = $request->query('status');

        $query = HostProfile::query();

        if ($status && VerificationStatus::tryFrom($status)) {
            $query->where('verification_status', VerificationStatus::from($status));
        } else {
            $query->where('verification_status', VerificationStatus::PENDING);
        }

        $profiles = $query->with('user')
            ->orderBy('created_at')
            ->paginate(20);

        return $this->paginatedResponse($profiles, AdminHostProfileResource::class, 'Verification requests retrieved successfully');
    }

    public function show(int $id): JsonResponse
    {
        $hostProfile = HostProfile::find($id);

        if (! $hostProfile) {
            return $this->errorResponse('Verification request not found', null, 404);
        }

        $hostProfile->load('user');

        return $this->successResponse(
            new AdminHostProfileResource($hostProfile),
            'Verification request retrieved successfully'
        );
    }

    public function approve(int $id): JsonResponse
    {
        $hostProfile = HostProfile::find($id);

        if (! $hostProfile) {
            return $this->errorResponse('Verification request not found', null, 404);
        }

        if ($hostProfile->verification_status === VerificationStatus::APPROVED) {
            return $this->errorResponse('Already approved', null, 422);
        }

        $previousStatus = $hostProfile->verification_status->value;

        $hostProfile->update([
            'verification_status' => VerificationStatus::APPROVED,
            'host_type' => HostType::VERIFIED,
            'verified_at' => now(),
        ]);

        activity()
            ->performedOn($hostProfile)
            ->causedBy(auth()->user())
            ->withProperties(['previous_status' => $previousStatus])
            ->log('host.verification_approved');

        event(new HostVerificationUpdated($hostProfile, VerificationStatus::APPROVED));

        $hostProfile->load('user');

        return $this->successResponse(
            new AdminHostProfileResource($hostProfile),
            'Host verified successfully'
        );
    }

    public function reject(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'admin_notes' => ['required', 'string', 'max:1000'],
        ]);

        $hostProfile = HostProfile::find($id);

        if (! $hostProfile) {
            return $this->errorResponse('Verification request not found', null, 404);
        }

        $hostProfile->update([
            'verification_status' => VerificationStatus::REJECTED,
            'admin_notes' => $request->input('admin_notes'),
        ]);

        activity()
            ->performedOn($hostProfile)
            ->causedBy(auth()->user())
            ->withProperties(['reason' => $request->input('admin_notes')])
            ->log('host.verification_rejected');

        event(new HostVerificationUpdated($hostProfile, VerificationStatus::REJECTED));

        $hostProfile->load('user');

        return $this->successResponse(
            new AdminHostProfileResource($hostProfile),
            'Verification rejected'
        );
    }
}
