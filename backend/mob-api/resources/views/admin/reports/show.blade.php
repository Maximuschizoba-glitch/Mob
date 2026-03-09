@extends('admin.layouts.app')

@section('title', 'Report #' . $report->id)
@section('page-title', 'Report Review')
@section('page-subtitle', ucfirst(str_replace('_', ' ', $report->reason->value)) . ' report')

@section('content')
    <!-- Back Link -->
    <div class="mb-6">
        <a href="{{ route('admin.reports.index') }}" class="text-mob-dim hover:text-mob-cyan text-sm transition-colors inline-flex items-center gap-1.5">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Reports
        </a>
    </div>

    @php
        $reportStatusColors = [
            'pending' => 'text-mob-red bg-mob-red/10 border-mob-red/20',
            'dismissed' => 'text-mob-dim bg-mob-elevated border-mob-border',
            'actioned' => 'text-mob-green bg-mob-green/10 border-mob-green/20',
        ];
        $currentStatusClass = $reportStatusColors[$report->status] ?? 'text-mob-dim bg-mob-elevated border-mob-border';

        $reasonColors = [
            'fake' => 'text-mob-amber bg-mob-amber/10 border-mob-amber/20',
            'scam' => 'text-mob-red bg-mob-red/10 border-mob-red/20',
            'misleading' => 'text-mob-purple bg-mob-purple/10 border-mob-purple/20',
            'wrong_location' => 'text-mob-cyan bg-mob-cyan/10 border-mob-cyan/20',
        ];
    @endphp

    <!-- Status Banner -->
    @if($report->isActioned())
        <div class="mb-6 bg-mob-green/10 border border-mob-green/20 rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-green shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <div class="flex-1">
                    <p class="text-mob-green font-semibold text-sm">Action Taken</p>
                    @if($report->action_taken)
                        <p class="text-mob-green/80 text-xs mt-0.5">Action: {{ ucfirst($report->action_taken) }}</p>
                    @endif
                    @if($report->reviewed_at)
                        <p class="text-mob-green/60 text-xs mt-0.5">Resolved on {{ $report->reviewed_at->format('M j, Y \a\t g:i A') }}</p>
                    @endif
                    @if($report->reviewer)
                        <p class="text-mob-green/60 text-xs mt-0.5">by {{ $report->reviewer->name }}</p>
                    @endif
                    @if($report->admin_notes)
                        <p class="text-mob-green/70 text-xs mt-2 italic">"{{ $report->admin_notes }}"</p>
                    @endif
                </div>
            </div>
        </div>
    @elseif($report->isDismissed())
        <div class="mb-6 bg-mob-elevated border border-mob-border rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-dim shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <div class="flex-1">
                    <p class="text-mob-muted font-semibold text-sm">Dismissed</p>
                    @if($report->reviewed_at)
                        <p class="text-mob-dim text-xs mt-0.5">Dismissed on {{ $report->reviewed_at->format('M j, Y \a\t g:i A') }}</p>
                    @endif
                    @if($report->reviewer)
                        <p class="text-mob-dim text-xs mt-0.5">by {{ $report->reviewer->name }}</p>
                    @endif
                    @if($report->admin_notes)
                        <p class="text-mob-dim text-xs mt-2 italic">"{{ $report->admin_notes }}"</p>
                    @endif
                </div>
            </div>
        </div>
    @endif

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h2 class="text-xl font-bold text-white">Report #{{ $report->id }}</h2>
            <p class="text-mob-dim text-xs mt-1">Submitted {{ $report->created_at->diffForHumans() }}</p>
        </div>
        <div class="flex items-center gap-2 self-start sm:self-auto">
            <span class="inline-block px-3 py-1.5 rounded-lg text-xs font-medium uppercase border {{ $reasonColors[$report->reason->value] ?? 'text-mob-dim bg-mob-elevated border-mob-border' }}">
                {{ str_replace('_', ' ', $report->reason->value) }}
            </span>
            <span class="inline-block px-3 py-1.5 rounded-lg text-xs font-medium uppercase border {{ $currentStatusClass }}">
                {{ $report->status }}
            </span>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Left Column -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Report Details -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Report Details</h3>
                </div>
                <div class="p-5 space-y-4">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Reason</p>
                            <span class="inline-block px-2.5 py-1 rounded-lg text-xs font-medium border {{ $reasonColors[$report->reason->value] ?? 'text-mob-dim bg-mob-elevated border-mob-border' }}">
                                {{ ucfirst(str_replace('_', ' ', $report->reason->value)) }}
                            </span>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Submitted</p>
                            <p class="text-white text-sm">{{ $report->created_at->format('M j, Y \a\t g:i A') }}</p>
                        </div>
                    </div>

                    @if($report->details)
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Reporter's Description</p>
                            <div class="bg-mob-elevated rounded-lg px-4 py-3">
                                <p class="text-mob-muted text-sm leading-relaxed">{{ $report->details }}</p>
                            </div>
                        </div>
                    @endif
                </div>
            </div>

            <!-- Reported Happening -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border flex items-center justify-between">
                    <h3 class="text-sm font-semibold text-white">Reported Happening</h3>
                    @if($totalReportsForHappening >= 3)
                        <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-medium text-mob-red bg-mob-red/10">
                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/></svg>
                            {{ $totalReportsForHappening }} reports
                        </span>
                    @endif
                </div>
                <div class="p-5">
                    @if($report->happening)
                        <div class="space-y-4">
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                <div>
                                    <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Title</p>
                                    <p class="text-white text-sm font-medium">{{ $report->happening->title }}</p>
                                </div>
                                <div>
                                    <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Creator</p>
                                    @if($report->happening->user)
                                        <a href="{{ route('admin.users.show', $report->happening->user) }}" class="text-mob-cyan text-sm font-medium hover:underline">
                                            {{ $report->happening->user->name }}
                                        </a>
                                    @else
                                        <p class="text-mob-dim text-sm">Unknown</p>
                                    @endif
                                </div>
                                <div>
                                    <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Status</p>
                                    @php
                                        $hapStatusColors = [
                                            'active' => 'text-mob-green bg-mob-green/10',
                                            'completed' => 'text-mob-dim bg-mob-elevated',
                                            'expired' => 'text-mob-dim bg-mob-elevated',
                                            'hidden' => 'text-mob-red bg-mob-red/10',
                                            'reported' => 'text-mob-amber bg-mob-amber/10',
                                        ];
                                    @endphp
                                    <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $hapStatusColors[$report->happening->status->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                        {{ $report->happening->status->value }}
                                    </span>
                                </div>
                                <div>
                                    <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Total Reports</p>
                                    <p class="text-white text-sm font-medium {{ $totalReportsForHappening >= 3 ? 'text-mob-red' : '' }}">{{ $totalReportsForHappening }}</p>
                                </div>
                            </div>

                            @if($report->happening->description)
                                <div>
                                    <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Description</p>
                                    <p class="text-mob-muted text-sm">{{ Str::limit($report->happening->description, 200) }}</p>
                                </div>
                            @endif

                            <div class="pt-2 border-t border-mob-border">
                                <a href="{{ route('admin.happenings.show', $report->happening) }}" class="text-mob-cyan text-xs font-medium hover:underline inline-flex items-center gap-1">
                                    View Full Happening Details
                                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
                                </a>
                            </div>
                        </div>
                    @else
                        <p class="text-mob-dim text-sm">This happening has been deleted.</p>
                    @endif
                </div>
            </div>

            <!-- Other Reports for Same Happening -->
            @if($relatedReports->isNotEmpty())
                <div class="bg-mob-card border border-mob-border rounded-xl">
                    <div class="px-5 py-4 border-b border-mob-border">
                        <h3 class="text-sm font-semibold text-white">Other Reports for This Happening</h3>
                        <p class="text-mob-dim text-xs mt-0.5">{{ $relatedReports->count() }} other {{ Str::plural('report', $relatedReports->count()) }}</p>
                    </div>
                    <div class="divide-y divide-mob-border">
                        @foreach($relatedReports as $related)
                            @php
                                $relReasonColors = [
                                    'fake' => 'text-mob-amber bg-mob-amber/10',
                                    'scam' => 'text-mob-red bg-mob-red/10',
                                    'misleading' => 'text-mob-purple bg-mob-purple/10',
                                    'wrong_location' => 'text-mob-cyan bg-mob-cyan/10',
                                ];
                                $relStatusColors = [
                                    'pending' => 'text-mob-red bg-mob-red/10',
                                    'dismissed' => 'text-mob-dim bg-mob-elevated',
                                    'actioned' => 'text-mob-green bg-mob-green/10',
                                ];
                            @endphp
                            <div class="px-5 py-3.5 flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <div class="w-6 h-6 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-[10px] font-bold shrink-0">
                                        {{ strtoupper(substr($related->user->name ?? '?', 0, 1)) }}
                                    </div>
                                    <div>
                                        <p class="text-white text-sm">{{ $related->user->name ?? 'Unknown' }}</p>
                                        <div class="flex items-center gap-2 mt-0.5">
                                            <span class="inline-block px-1.5 py-0.5 rounded text-[9px] font-medium uppercase {{ $relReasonColors[$related->reason->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                                {{ str_replace('_', ' ', $related->reason->value) }}
                                            </span>
                                            <span class="text-mob-dim text-[10px]">{{ $related->created_at->diffForHumans() }}</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="flex items-center gap-2">
                                    <span class="inline-block px-1.5 py-0.5 rounded text-[9px] font-medium uppercase {{ $relStatusColors[$related->status] ?? 'text-mob-dim bg-mob-elevated' }}">
                                        {{ $related->status }}
                                    </span>
                                    <a href="{{ route('admin.reports.show', $related) }}" class="text-mob-cyan text-xs hover:underline">View</a>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            @endif

            <!-- Admin Actions (for pending reports) -->
            @if($report->isPending())
                <div class="bg-mob-card border border-mob-border rounded-xl">
                    <div class="px-5 py-4 border-b border-mob-border">
                        <h3 class="text-sm font-semibold text-white">Admin Actions</h3>
                    </div>
                    <div class="p-5">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                            <!-- Dismiss -->
                            <div class="p-4 border border-mob-border rounded-xl bg-mob-elevated/30">
                                <h4 class="text-mob-muted text-sm font-semibold mb-2">Dismiss Report</h4>
                                <p class="text-mob-dim text-xs mb-3">No action needed. The reported content does not violate guidelines.</p>
                                <form method="POST" action="{{ route('admin.reports.dismiss', $report) }}">
                                    @csrf
                                    <textarea
                                        name="admin_notes"
                                        rows="2"
                                        placeholder="Dismissal notes (optional)..."
                                        class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none resize-none mb-3"
                                    ></textarea>
                                    <button type="submit"
                                            class="w-full px-4 py-2.5 text-sm font-medium rounded-lg bg-mob-elevated text-mob-muted hover:text-white border border-mob-border hover:border-mob-dim transition-colors cursor-pointer"
                                            onclick="return confirm('Dismiss this report? The happening will remain visible.')">
                                        Dismiss Report
                                    </button>
                                </form>
                            </div>

                            <!-- Take Action: Hide -->
                            <div class="p-4 border border-mob-red/20 rounded-xl bg-mob-red/5">
                                <h4 class="text-mob-red text-sm font-semibold mb-2">Hide Happening</h4>
                                <p class="text-mob-dim text-xs mb-3">Remove the happening from public feed. The creator will be notified.</p>
                                <form method="POST" action="{{ route('admin.reports.action', $report) }}">
                                    @csrf
                                    <input type="hidden" name="action" value="hide">
                                    <textarea
                                        name="admin_notes"
                                        rows="2"
                                        placeholder="Action notes (optional)..."
                                        class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-red focus:outline-none resize-none mb-3"
                                    ></textarea>
                                    <button type="submit"
                                            class="w-full px-4 py-2.5 text-sm font-medium rounded-lg bg-mob-red/15 text-mob-red hover:bg-mob-red/25 transition-colors cursor-pointer"
                                            onclick="return confirm('Hide this happening from the feed? This will remove it from public view.')">
                                        Hide Happening
                                    </button>
                                </form>
                            </div>
                        </div>

                        <!-- Warn Only -->
                        <div class="mt-4 p-4 border border-mob-amber/20 rounded-xl bg-mob-amber/5">
                            <h4 class="text-mob-amber text-sm font-semibold mb-2">Flag &amp; Warn</h4>
                            <p class="text-mob-dim text-xs mb-3">Mark as reviewed and flag the host. The happening stays visible but is monitored.</p>
                            <form method="POST" action="{{ route('admin.reports.action', $report) }}">
                                @csrf
                                <input type="hidden" name="action" value="warn">
                                <textarea
                                    name="admin_notes"
                                    rows="2"
                                    placeholder="Warning notes (optional)..."
                                    class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-amber focus:outline-none resize-none mb-3"
                                ></textarea>
                                <button type="submit"
                                        class="w-full px-4 py-2.5 text-sm font-medium rounded-lg bg-mob-amber/15 text-mob-amber hover:bg-mob-amber/25 transition-colors cursor-pointer"
                                        onclick="return confirm('Flag this host for warning? The happening will remain visible.')">
                                    Flag &amp; Warn Host
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            @endif
        </div>

        <!-- Right Column: Sidebar -->
        <div class="space-y-6">
            <!-- Reporter Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Reporter</h3>
                </div>
                <div class="p-5">
                    @if($report->user)
                        <a href="{{ route('admin.users.show', $report->user) }}" class="flex items-center gap-3 group">
                            <div class="w-10 h-10 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-sm font-bold shrink-0">
                                {{ strtoupper(substr($report->user->name, 0, 1)) }}
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm text-white group-hover:text-mob-cyan transition-colors font-medium truncate">{{ $report->user->name }}</p>
                                <p class="text-xs text-mob-dim truncate">{{ $report->user->email }}</p>
                            </div>
                        </a>
                    @else
                        <p class="text-mob-dim text-sm">Reporter not found.</p>
                    @endif
                </div>
            </div>

            <!-- Happening Creator -->
            @if($report->happening?->user)
                <div class="bg-mob-card border border-mob-border rounded-xl">
                    <div class="px-5 py-4 border-b border-mob-border">
                        <h3 class="text-sm font-semibold text-white">Happening Creator</h3>
                    </div>
                    <div class="p-5">
                        <a href="{{ route('admin.users.show', $report->happening->user) }}" class="flex items-center gap-3 group">
                            <div class="w-10 h-10 rounded-full bg-mob-elevated flex items-center justify-center text-mob-purple text-sm font-bold shrink-0">
                                {{ strtoupper(substr($report->happening->user->name, 0, 1)) }}
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm text-white group-hover:text-mob-cyan transition-colors font-medium truncate">{{ $report->happening->user->name }}</p>
                                <p class="text-xs text-mob-dim truncate">{{ $report->happening->user->email }}</p>
                            </div>
                        </a>
                        <div class="mt-3 pt-3 border-t border-mob-border">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Role</span>
                                <span class="text-mob-purple capitalize font-medium">{{ $report->happening->user->role->value }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            @endif

            <!-- Quick Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Details</h3>
                </div>
                <div class="p-5 space-y-3">
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Report ID</span>
                        <span class="text-mob-muted">#{{ $report->id }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Reason</span>
                        <span class="text-mob-muted capitalize">{{ str_replace('_', ' ', $report->reason->value) }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Status</span>
                        <span class="text-mob-muted capitalize">{{ $report->status }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Submitted</span>
                        <span class="text-mob-muted">{{ $report->created_at->format('M j, Y') }}</span>
                    </div>
                    @if($report->action_taken)
                        <div class="flex items-center justify-between text-xs pt-2 border-t border-mob-border">
                            <span class="text-mob-dim">Action Taken</span>
                            <span class="text-mob-muted capitalize font-medium">{{ $report->action_taken }}</span>
                        </div>
                    @endif
                    @if($report->reviewed_at)
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-mob-dim">Reviewed</span>
                            <span class="text-mob-muted">{{ $report->reviewed_at->diffForHumans() }}</span>
                        </div>
                    @endif
                    @if($report->reviewer)
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-mob-dim">Reviewed By</span>
                            <span class="text-mob-muted">{{ $report->reviewer->name }}</span>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
