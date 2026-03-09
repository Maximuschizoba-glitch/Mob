<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Enums\VerificationStatus;
use App\Http\Controllers\Controller;
use App\Models\HostProfile;
use Illuminate\Http\Request;

class VerificationController extends Controller
{
    public function index(Request $request)
    {
        $query = HostProfile::with('user');


        $status = $request->input('status', 'pending');

        if ($status !== 'all') {
            $query->where('verification_status', $status);
        }


        $query->orderByRaw("FIELD(verification_status, 'pending', 'rejected', 'approved')")
              ->latest();

        $verifications = $query->paginate(20)->withQueryString();

        $counts = [
            'pending' => HostProfile::where('verification_status', VerificationStatus::PENDING)->count(),
            'approved' => HostProfile::where('verification_status', VerificationStatus::APPROVED)->count(),
            'rejected' => HostProfile::where('verification_status', VerificationStatus::REJECTED)->count(),
            'total' => HostProfile::count(),
        ];

        return view('admin.verifications.index', compact('verifications', 'counts', 'status'));
    }

    public function show(HostProfile $hostProfile)
    {
        $hostProfile->load(['user', 'reviewer']);

        return view('admin.verifications.show', compact('hostProfile'));
    }

    public function approve(Request $request, HostProfile $hostProfile)
    {
        if (!$hostProfile->isPending()) {
            return back()->with('error', 'This verification has already been reviewed.');
        }

        $hostProfile->update([
            'verification_status' => VerificationStatus::APPROVED,
            'verified_at' => now(),
            'reviewed_by' => auth()->id(),
            'reviewed_at' => now(),
            'admin_notes' => $request->input('admin_notes'),
            'rejection_reason' => null,
        ]);


        $user = $hostProfile->user;
        if ($user && $user->role === UserRole::USER) {
            $user->update(['role' => UserRole::HOST]);
        }

        return redirect()->route('admin.verifications.show', $hostProfile)
            ->with('success', "{$user->name} has been approved as a verified host.");
    }

    public function reject(Request $request, HostProfile $hostProfile)
    {
        $request->validate([
            'rejection_reason' => 'required|string|max:500',
        ]);

        if (!$hostProfile->isPending()) {
            return back()->with('error', 'This verification has already been reviewed.');
        }

        $hostProfile->update([
            'verification_status' => VerificationStatus::REJECTED,
            'reviewed_by' => auth()->id(),
            'reviewed_at' => now(),
            'rejection_reason' => $request->input('rejection_reason'),
            'admin_notes' => $request->input('admin_notes'),
        ]);

        return redirect()->route('admin.verifications.show', $hostProfile)
            ->with('success', "Verification for {$hostProfile->user->name} has been rejected.");
    }
}
