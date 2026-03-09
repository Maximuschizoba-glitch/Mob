<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\EscrowStatus;
use App\Enums\HappeningStatus;
use App\Enums\UserRole;
use App\Enums\VerificationStatus;
use App\Http\Controllers\Api\V1\BaseController;
use App\Models\Escrow;
use App\Models\Happening;
use App\Models\HostProfile;
use App\Models\Report;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Spatie\Activitylog\Models\Activity;

class DashboardController extends BaseController
{
    public function index(): JsonResponse
    {
        $stats = [
            'total_users' => User::where('is_guest', false)->count(),
            'total_guests' => User::where('is_guest', true)->count(),
            'total_hosts' => User::where('role', UserRole::HOST)->count(),
            'total_happenings' => Happening::count(),
            'active_happenings' => Happening::where('status', HappeningStatus::ACTIVE)
                ->where('expires_at', '>', now())
                ->count(),
            'total_reports' => Report::count(),
            'pending_reports' => Report::where('status', 'pending')->count(),
            'pending_verifications' => HostProfile::where('verification_status', VerificationStatus::PENDING)->count(),
            'total_escrows' => Escrow::count(),
            'escrows_awaiting_approval' => Escrow::where('status', EscrowStatus::AWAITING_COMPLETION)->count(),
            'escrows_refunding' => Escrow::where('status', EscrowStatus::REFUNDING)->count(),
            'total_revenue' => (float) Escrow::where('status', EscrowStatus::RELEASED)->sum('platform_fee'),
        ];

        return $this->successResponse($stats, 'Dashboard stats retrieved successfully');
    }

    public function activityLog(Request $request): JsonResponse
    {
        $query = Activity::query();

        $query->where('log_name', $request->query('log_name', 'admin'));

        if ($request->has('subject_type')) {
            $query->where('subject_type', $request->query('subject_type'));
        }

        if ($request->has('causer_id')) {
            $query->where('causer_id', $request->query('causer_id'));
        }

        $activities = $query->with(['causer', 'subject'])
            ->orderByDesc('created_at')
            ->paginate(30);

        $data = $activities->through(function ($activity) {
            return [
                'id' => $activity->id,
                'description' => $activity->description,
                'properties' => $activity->properties->toArray(),
                'causer' => $activity->causer ? [
                    'name' => $activity->causer->name,
                    'uuid' => $activity->causer->uuid ?? null,
                ] : null,
                'subject_type' => $activity->subject_type,
                'subject_id' => $activity->subject_id,
                'created_at' => $activity->created_at?->toIso8601String(),
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Activity log retrieved successfully',
            'data' => $data->items(),
            'meta' => [
                'current_page' => $data->currentPage(),
                'per_page' => $data->perPage(),
                'total' => $data->total(),
                'last_page' => $data->lastPage(),
            ],
        ]);
    }
}
