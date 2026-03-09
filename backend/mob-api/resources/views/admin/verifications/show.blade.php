@extends('admin.layouts.app')

@section('title', 'Verification: ' . ($hostProfile->user->name ?? 'Unknown'))
@section('page-title', 'Verification Review')
@section('page-subtitle', ($hostProfile->business_name ?? $hostProfile->user->name ?? 'Unknown'))

@section('content')
    <!-- Back Link -->
    <div class="mb-6">
        <a href="{{ route('admin.verifications.index') }}" class="text-mob-dim hover:text-mob-cyan text-sm transition-colors inline-flex items-center gap-1.5">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Verifications
        </a>
    </div>

    <!-- Status Banner -->
    @if($hostProfile->isApproved())
        <div class="mb-6 bg-mob-green/10 border border-mob-green/20 rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-green shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <div class="flex-1">
                    <p class="text-mob-green font-semibold text-sm">Approved</p>
                    @if($hostProfile->verified_at)
                        <p class="text-mob-green/70 text-xs mt-0.5">Approved on {{ $hostProfile->verified_at->format('M j, Y \a\t g:i A') }}</p>
                    @endif
                    @if($hostProfile->reviewer)
                        <p class="text-mob-green/60 text-xs mt-0.5">by {{ $hostProfile->reviewer->name }}</p>
                    @endif
                </div>
            </div>
        </div>
    @elseif($hostProfile->isRejected())
        <div class="mb-6 bg-mob-red/10 border border-mob-red/20 rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-red shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <div class="flex-1">
                    <p class="text-mob-red font-semibold text-sm">Rejected</p>
                    @if($hostProfile->rejection_reason)
                        <p class="text-mob-red/80 text-xs mt-1">Reason: {{ $hostProfile->rejection_reason }}</p>
                    @endif
                    @if($hostProfile->reviewed_at)
                        <p class="text-mob-red/60 text-xs mt-0.5">Rejected on {{ $hostProfile->reviewed_at->format('M j, Y \a\t g:i A') }}</p>
                    @endif
                    @if($hostProfile->reviewer)
                        <p class="text-mob-red/60 text-xs mt-0.5">by {{ $hostProfile->reviewer->name }}</p>
                    @endif
                </div>
            </div>
        </div>
    @else
        <div class="mb-6 bg-mob-amber/10 border border-mob-amber/20 rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-amber shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <div class="flex-1">
                    <p class="text-mob-amber font-semibold text-sm">Pending Review</p>
                    <p class="text-mob-amber/70 text-xs mt-0.5">Submitted {{ $hostProfile->created_at->diffForHumans() }}</p>
                </div>
            </div>
        </div>
    @endif

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Left Column: Details -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Applicant Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Applicant Info</h3>
                </div>
                <div class="p-5">
                    <div class="flex items-start gap-4 mb-5">
                        <div class="w-14 h-14 rounded-full bg-mob-elevated flex items-center justify-center text-mob-purple text-lg font-bold shrink-0">
                            {{ strtoupper(substr($hostProfile->user->name ?? '?', 0, 1)) }}
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center gap-2 mb-1">
                                <h4 class="text-white font-semibold text-base">{{ $hostProfile->user->name ?? 'Unknown' }}</h4>
                                @php
                                    $roleColors = [
                                        'admin' => 'text-mob-cyan bg-mob-cyan/10',
                                        'host' => 'text-mob-purple bg-mob-purple/10',
                                        'moderator' => 'text-mob-amber bg-mob-amber/10',
                                        'user' => 'text-mob-dim bg-mob-elevated',
                                        'guest' => 'text-mob-dim bg-mob-elevated',
                                    ];
                                    $roleClass = $roleColors[$hostProfile->user->role->value] ?? 'text-mob-dim bg-mob-elevated';
                                @endphp
                                <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $roleClass }}">
                                    {{ $hostProfile->user->role->value }}
                                </span>
                            </div>
                            <p class="text-mob-dim text-sm">{{ $hostProfile->user->email ?? '--' }}</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 text-sm">
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Phone</p>
                            <p class="text-white">{{ $hostProfile->user->phone ?? '--' }}</p>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Joined</p>
                            <p class="text-white">{{ $hostProfile->user->created_at->format('M j, Y') }}</p>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Phone Verified</p>
                            @if($hostProfile->user->phone_verified_at)
                                <span class="text-mob-green text-xs font-medium">Yes</span>
                            @else
                                <span class="text-mob-red text-xs font-medium">No</span>
                            @endif
                        </div>
                    </div>

                    @if($hostProfile->user)
                        <div class="mt-4 pt-4 border-t border-mob-border">
                            <a href="{{ route('admin.users.show', $hostProfile->user) }}" class="text-mob-cyan text-xs font-medium hover:underline">
                                View Full User Profile &rarr;
                            </a>
                        </div>
                    @endif
                </div>
            </div>

            <!-- Business Details -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Business Details</h3>
                </div>
                <div class="p-5">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Business Name</p>
                            <p class="text-white">{{ $hostProfile->business_name ?? '--' }}</p>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Host Type</p>
                            @php
                                $hostTypeColors = [
                                    'verified' => 'text-mob-purple bg-mob-purple/10',
                                    'community' => 'text-mob-cyan bg-mob-cyan/10',
                                ];
                                $hostTypeClass = $hostTypeColors[$hostProfile->host_type->value] ?? 'text-mob-dim bg-mob-elevated';
                            @endphp
                            <span class="inline-block px-2.5 py-0.5 rounded text-xs font-medium uppercase {{ $hostTypeClass }}">
                                {{ $hostProfile->host_type->value }}
                            </span>
                        </div>
                        @if($hostProfile->bio)
                            <div class="sm:col-span-2">
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Bio</p>
                                <p class="text-mob-muted text-sm leading-relaxed">{{ $hostProfile->bio }}</p>
                            </div>
                        @endif
                    </div>
                </div>
            </div>

            <!-- Verification Document -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Verification Document</h3>
                </div>
                <div class="p-5">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm mb-4">
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Document Type</p>
                            @if($hostProfile->verification_document_type)
                                @php
                                    $docLabels = [
                                        'cac' => 'CAC Registration',
                                        'instagram' => 'Instagram Page',
                                        'website' => 'Website URL',
                                    ];
                                    $docLabel = $docLabels[$hostProfile->verification_document_type] ?? strtoupper($hostProfile->verification_document_type);
                                @endphp
                                <span class="inline-block px-2.5 py-0.5 rounded text-xs font-medium uppercase bg-mob-elevated text-mob-muted">
                                    {{ $docLabel }}
                                </span>
                            @else
                                <span class="text-mob-dim text-xs">No document type specified</span>
                            @endif
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Submitted</p>
                            <p class="text-white text-sm">{{ $hostProfile->created_at->format('M j, Y \a\t g:i A') }}</p>
                        </div>
                    </div>

                    @if($hostProfile->verification_document_url)
                        <div class="mt-4 p-4 bg-mob-elevated rounded-lg border border-mob-border">
                            <div class="flex items-center justify-between gap-3">
                                <div class="flex items-center gap-3 min-w-0">
                                    <div class="w-10 h-10 rounded-lg bg-mob-card flex items-center justify-center shrink-0">
                                        @if(in_array($hostProfile->verification_document_type, ['instagram', 'website']))
                                            <svg class="w-5 h-5 text-mob-cyan" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/></svg>
                                        @else
                                            <svg class="w-5 h-5 text-mob-cyan" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                                        @endif
                                    </div>
                                    <div class="min-w-0">
                                        <p class="text-white text-sm font-medium truncate">{{ $hostProfile->verification_document_url }}</p>
                                        <p class="text-mob-dim text-xs mt-0.5">{{ ucfirst($hostProfile->verification_document_type ?? 'Document') }}</p>
                                    </div>
                                </div>
                                <a href="{{ $hostProfile->verification_document_url }}"
                                   target="_blank"
                                   rel="noopener noreferrer"
                                   class="px-4 py-2 bg-mob-cyan/10 text-mob-cyan text-xs font-medium rounded-lg hover:bg-mob-cyan/20 transition-colors shrink-0">
                                    Open
                                </a>
                            </div>
                        </div>
                    @else
                        <div class="mt-4 p-4 bg-mob-elevated rounded-lg border border-mob-border text-center">
                            <svg class="w-8 h-8 text-mob-dim mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                            <p class="text-mob-dim text-xs">No document uploaded</p>
                        </div>
                    @endif
                </div>
            </div>

            <!-- Review History -->
            @if($hostProfile->admin_notes || $hostProfile->rejection_reason || $hostProfile->reviewed_at)
                <div class="bg-mob-card border border-mob-border rounded-xl">
                    <div class="px-5 py-4 border-b border-mob-border">
                        <h3 class="text-sm font-semibold text-white">Review History</h3>
                    </div>
                    <div class="p-5 space-y-4">
                        @if($hostProfile->reviewed_at)
                            <div class="flex items-start gap-3">
                                <div class="w-8 h-8 rounded-full flex items-center justify-center shrink-0 mt-0.5
                                    {{ $hostProfile->isApproved() ? 'bg-mob-green/10' : 'bg-mob-red/10' }}">
                                    @if($hostProfile->isApproved())
                                        <svg class="w-4 h-4 text-mob-green" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                                    @else
                                        <svg class="w-4 h-4 text-mob-red" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                                    @endif
                                </div>
                                <div class="flex-1">
                                    <p class="text-white text-sm font-medium">
                                        {{ $hostProfile->isApproved() ? 'Approved' : 'Rejected' }}
                                        @if($hostProfile->reviewer)
                                            <span class="text-mob-dim font-normal">by {{ $hostProfile->reviewer->name }}</span>
                                        @endif
                                    </p>
                                    <p class="text-mob-dim text-xs mt-0.5">{{ $hostProfile->reviewed_at->format('M j, Y \a\t g:i A') }}</p>

                                    @if($hostProfile->rejection_reason)
                                        <div class="mt-2 p-3 bg-mob-elevated rounded-lg">
                                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Rejection Reason</p>
                                            <p class="text-mob-muted text-sm">{{ $hostProfile->rejection_reason }}</p>
                                        </div>
                                    @endif

                                    @if($hostProfile->admin_notes)
                                        <div class="mt-2 p-3 bg-mob-elevated rounded-lg">
                                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Admin Notes</p>
                                            <p class="text-mob-muted text-sm">{{ $hostProfile->admin_notes }}</p>
                                        </div>
                                    @endif
                                </div>
                            </div>
                        @endif
                    </div>
                </div>
            @endif
        </div>

        <!-- Right Column: Actions -->
        <div class="space-y-6">
            <!-- Current Status Card -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Status</h3>
                </div>
                <div class="p-5">
                    @if($hostProfile->isPending())
                        <div class="flex items-center gap-2">
                            <span class="relative flex h-2.5 w-2.5">
                                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-mob-amber opacity-75"></span>
                                <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-mob-amber"></span>
                            </span>
                            <span class="text-mob-amber text-sm font-medium">Pending Review</span>
                        </div>
                        <p class="text-mob-dim text-xs mt-2">Waiting {{ $hostProfile->created_at->diffForHumans(null, true) }}</p>
                    @elseif($hostProfile->isApproved())
                        <div class="flex items-center gap-2">
                            <svg class="w-4 h-4 text-mob-green" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            <span class="text-mob-green text-sm font-medium">Approved</span>
                        </div>
                        @if($hostProfile->verified_at)
                            <p class="text-mob-dim text-xs mt-2">{{ $hostProfile->verified_at->format('M j, Y') }}</p>
                        @endif
                    @elseif($hostProfile->isRejected())
                        <div class="flex items-center gap-2">
                            <svg class="w-4 h-4 text-mob-red" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            <span class="text-mob-red text-sm font-medium">Rejected</span>
                        </div>
                        @if($hostProfile->reviewed_at)
                            <p class="text-mob-dim text-xs mt-2">{{ $hostProfile->reviewed_at->format('M j, Y') }}</p>
                        @endif
                    @endif
                </div>
            </div>

            <!-- Actions (only for pending) -->
            @if($hostProfile->isPending())
                <!-- Approve Form -->
                <div class="bg-mob-card border border-mob-border rounded-xl">
                    <div class="px-5 py-4 border-b border-mob-border">
                        <h3 class="text-sm font-semibold text-mob-green">Approve Verification</h3>
                    </div>
                    <form action="{{ route('admin.verifications.approve', $hostProfile) }}" method="POST" class="p-5">
                        @csrf
                        <div class="mb-4">
                            <label for="approve_notes" class="block text-mob-dim text-xs uppercase tracking-wider mb-2">
                                Admin Notes <span class="normal-case tracking-normal">(optional)</span>
                            </label>
                            <textarea
                                id="approve_notes"
                                name="admin_notes"
                                rows="2"
                                placeholder="Optional notes about approval..."
                                class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-green focus:outline-none resize-none"
                            ></textarea>
                        </div>
                        <p class="text-mob-dim text-xs mb-4">This will upgrade the user's role to <span class="text-mob-purple font-medium">Host</span> and grant verification badge.</p>
                        <button type="submit"
                                class="w-full px-4 py-2.5 text-sm font-medium rounded-lg bg-mob-green/15 text-mob-green hover:bg-mob-green/25 transition-colors cursor-pointer"
                                onclick="return confirm('Approve this host verification? The user will be upgraded to Host role.')">
                            Approve Host
                        </button>
                    </form>
                </div>

                <!-- Reject Form -->
                <div class="bg-mob-card border border-mob-border rounded-xl">
                    <div class="px-5 py-4 border-b border-mob-border">
                        <h3 class="text-sm font-semibold text-mob-red">Reject Verification</h3>
                    </div>
                    <form action="{{ route('admin.verifications.reject', $hostProfile) }}" method="POST" class="p-5">
                        @csrf
                        <div class="mb-4">
                            <label for="reject_reason" class="block text-mob-dim text-xs uppercase tracking-wider mb-2">
                                Rejection Reason <span class="text-mob-red">*</span>
                            </label>
                            <textarea
                                id="reject_reason"
                                name="rejection_reason"
                                rows="3"
                                required
                                placeholder="Explain why this verification is being rejected..."
                                class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-red focus:outline-none resize-none"
                            ></textarea>
                            @error('rejection_reason')
                                <p class="text-mob-red text-xs mt-1">{{ $message }}</p>
                            @enderror
                        </div>
                        <div class="mb-4">
                            <label for="reject_notes" class="block text-mob-dim text-xs uppercase tracking-wider mb-2">
                                Internal Notes <span class="normal-case tracking-normal">(optional)</span>
                            </label>
                            <textarea
                                id="reject_notes"
                                name="admin_notes"
                                rows="2"
                                placeholder="Internal notes (not shown to user)..."
                                class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-amber focus:outline-none resize-none"
                            ></textarea>
                        </div>
                        <button type="submit"
                                class="w-full px-4 py-2.5 text-sm font-medium rounded-lg bg-mob-red/15 text-mob-red hover:bg-mob-red/25 transition-colors cursor-pointer"
                                onclick="return confirm('Reject this host verification?')">
                            Reject Application
                        </button>
                    </form>
                </div>
            @endif

            <!-- Quick Info Card -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Quick Info</h3>
                </div>
                <div class="p-5 space-y-3 text-sm">
                    <div class="flex items-center justify-between">
                        <span class="text-mob-dim text-xs">Profile ID</span>
                        <span class="text-mob-muted text-xs font-mono">#{{ $hostProfile->id }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-mob-dim text-xs">Submitted</span>
                        <span class="text-mob-muted text-xs">{{ $hostProfile->created_at->format('M j, Y') }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-mob-dim text-xs">Last Updated</span>
                        <span class="text-mob-muted text-xs">{{ $hostProfile->updated_at->format('M j, Y') }}</span>
                    </div>
                    @if($hostProfile->user)
                        <div class="flex items-center justify-between">
                            <span class="text-mob-dim text-xs">User Role</span>
                            <span class="text-mob-muted text-xs capitalize">{{ $hostProfile->user->role->value }}</span>
                        </div>
                        <div class="flex items-center justify-between">
                            <span class="text-mob-dim text-xs">User Status</span>
                            @if($hostProfile->user->isSuspended())
                                <span class="text-mob-red text-xs font-medium">Suspended</span>
                            @else
                                <span class="text-mob-green text-xs font-medium">Active</span>
                            @endif
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
