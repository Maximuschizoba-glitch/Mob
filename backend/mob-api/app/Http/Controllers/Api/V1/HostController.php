<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\HostType;
use App\Enums\UserRole;
use App\Enums\VerificationStatus;
use App\Http\Requests\Host\RequestVerificationRequest;
use App\Http\Resources\HostProfileResource;
use Illuminate\Http\JsonResponse;

class HostController extends BaseController
{
    public function requestVerification(RequestVerificationRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();
        $existingProfile = $user->hostProfile;

        if ($existingProfile) {
            if ($existingProfile->verification_status === VerificationStatus::APPROVED) {
                return $this->errorResponse('You are already verified', null, 422);
            }

            if ($existingProfile->verification_status === VerificationStatus::PENDING) {
                return $this->errorResponse('You already have a pending verification request', null, 422);
            }
        }

        $profileData = [
            'user_id' => $user->id,
            'host_type' => $validated['host_type'] ?? HostType::COMMUNITY->value,
            'business_name' => $validated['business_name'],
            'bio' => $validated['bio'] ?? null,
            'verification_status' => VerificationStatus::PENDING,
            'verification_document_url' => $validated['document_url'],
            'verification_document_type' => $validated['document_type'],
        ];

        if ($existingProfile) {
            $existingProfile->update($profileData);
            $hostProfile = $existingProfile;
        } else {
            $hostProfile = $user->hostProfile()->create($profileData);
        }

        if ($user->role === UserRole::USER) {
            $user->role = UserRole::HOST;
            $user->save();
        }

        $hostProfile->load('user');

        return $this->successResponse(
            new HostProfileResource($hostProfile),
            'Verification request submitted. You will be notified once reviewed.',
            201
        );
    }

    public function verificationStatus(): JsonResponse
    {
        $user = auth()->user();
        $hostProfile = $user->hostProfile;

        if (! $hostProfile) {
            return $this->errorResponse('No verification request found', null, 404);
        }

        $hostProfile->load('user');

        return $this->successResponse(
            new HostProfileResource($hostProfile),
            'Verification status retrieved successfully'
        );
    }
}
