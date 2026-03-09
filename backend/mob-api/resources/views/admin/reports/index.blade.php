@extends('admin.layouts.app')

@section('title', 'Reports')
@section('page-title', 'Report Queue')
@section('page-subtitle', $counts['pending'] . ' pending review')

@section('content')
    <!-- Stats Row -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Pending</p>
            <p class="text-lg font-bold text-mob-red">{{ number_format($counts['pending']) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Awaiting review</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Flagged Happenings</p>
            <p class="text-lg font-bold text-mob-amber">{{ number_format($flaggedCount) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">3+ reports (auto-hide threshold)</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Actioned</p>
            <p class="text-lg font-bold text-mob-green">{{ number_format($counts['actioned']) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Action taken</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Dismissed</p>
            <p class="text-lg font-bold text-mob-dim">{{ number_format($counts['dismissed']) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">No action needed</p>
        </div>
    </div>

    <!-- Tab Pills -->
    <div class="flex flex-wrap items-center gap-2 mb-6">
        @php
            $tabs = [
                'pending' => ['label' => 'Pending', 'count' => $counts['pending'], 'color' => 'mob-red'],
                'actioned' => ['label' => 'Actioned', 'count' => $counts['actioned'], 'color' => 'mob-green'],
                'dismissed' => ['label' => 'Dismissed', 'count' => $counts['dismissed'], 'color' => 'mob-dim'],
                'all' => ['label' => 'All', 'count' => $counts['total'], 'color' => 'mob-cyan'],
            ];
        @endphp
        @foreach($tabs as $value => $tab)
            <a href="{{ route('admin.reports.index', array_merge(request()->only(['search', 'reason']), $value === 'pending' ? [] : ['status' => $value])) }}"
               class="px-3 py-1.5 text-xs font-medium rounded-lg transition-colors inline-flex items-center gap-1.5
                   {{ $status === $value
                       ? 'bg-mob-cyan/10 text-mob-cyan border border-mob-cyan/30'
                       : 'bg-mob-card text-mob-muted border border-mob-border hover:text-white' }}">
                {{ $tab['label'] }}
                @if($tab['count'] > 0)
                    <span class="text-[10px] px-1.5 py-0.5 rounded-full font-semibold
                        {{ $status === $value ? 'bg-mob-cyan/20 text-mob-cyan' : 'bg-mob-elevated text-mob-dim' }}">
                        {{ $tab['count'] }}
                    </span>
                @endif
            </a>
        @endforeach
    </div>

    <!-- Search & Filters -->
    <div class="bg-mob-card border border-mob-border rounded-xl p-4 mb-6">
        <form method="GET" action="{{ route('admin.reports.index') }}" class="flex flex-col sm:flex-row gap-3">
            @if($status !== 'pending')
                <input type="hidden" name="status" value="{{ $status }}">
            @endif
            <div class="flex-1">
                <input
                    type="text"
                    name="search"
                    value="{{ request('search') }}"
                    placeholder="Search by happening title or reporter name..."
                    class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none transition-colors"
                />
            </div>
            <div class="w-full sm:w-44">
                <select
                    name="reason"
                    class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white focus:border-mob-cyan focus:outline-none transition-colors appearance-none"
                >
                    <option value="">All Reasons</option>
                    @foreach(\App\Enums\ReportReason::cases() as $reason)
                        <option value="{{ $reason->value }}" {{ request('reason') === $reason->value ? 'selected' : '' }}>
                            {{ ucfirst(str_replace('_', ' ', $reason->value)) }}
                        </option>
                    @endforeach
                </select>
            </div>
            <button
                type="submit"
                class="px-5 py-2.5 bg-mob-cyan/10 text-mob-cyan text-sm font-medium rounded-lg hover:bg-mob-cyan/20 transition-colors cursor-pointer"
            >
                Search
            </button>
            @if(request('search') || request('reason'))
                <a
                    href="{{ route('admin.reports.index', $status !== 'pending' ? ['status' => $status] : []) }}"
                    class="px-5 py-2.5 bg-mob-elevated text-mob-muted text-sm font-medium rounded-lg hover:text-white transition-colors text-center"
                >
                    Clear
                </a>
            @endif
        </form>
    </div>

    <!-- Reports Table -->
    <div class="bg-mob-card border border-mob-border rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left">
                <thead>
                    <tr class="border-b border-mob-border">
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Happening</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Reporter</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Reason</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Status</th>
                        @if($status !== 'pending')
                            <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Action</th>
                        @endif
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Submitted</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-mob-border">
                    @forelse($reports as $report)
                        @php
                            $reportStatusColors = [
                                'pending' => 'text-mob-red bg-mob-red/10',
                                'dismissed' => 'text-mob-dim bg-mob-elevated',
                                'actioned' => 'text-mob-green bg-mob-green/10',
                            ];
                            $reasonColors = [
                                'fake' => 'text-mob-amber bg-mob-amber/10',
                                'scam' => 'text-mob-red bg-mob-red/10',
                                'misleading' => 'text-mob-purple bg-mob-purple/10',
                                'wrong_location' => 'text-mob-cyan bg-mob-cyan/10',
                            ];
                        @endphp
                        <tr class="hover:bg-mob-elevated/50 transition-colors">
                            <td class="px-5 py-3.5">
                                <div>
                                    <a href="{{ route('admin.reports.show', $report) }}" class="text-white hover:text-mob-cyan text-sm font-medium transition-colors truncate block max-w-[200px]">
                                        {{ $report->happening->title ?? 'Deleted Happening' }}
                                    </a>
                                    @if($report->happening?->user)
                                        <p class="text-mob-dim text-xs mt-0.5">by {{ $report->happening->user->name }}</p>
                                    @endif
                                </div>
                            </td>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-2">
                                    <div class="w-6 h-6 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-[10px] font-bold shrink-0">
                                        {{ strtoupper(substr($report->user->name ?? '?', 0, 1)) }}
                                    </div>
                                    <span class="text-mob-muted text-sm truncate max-w-[100px]">{{ $report->user->name ?? 'Unknown' }}</span>
                                </div>
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $reasonColors[$report->reason->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                    {{ str_replace('_', ' ', $report->reason->value) }}
                                </span>
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $reportStatusColors[$report->status] ?? 'text-mob-dim bg-mob-elevated' }}">
                                    {{ $report->status }}
                                </span>
                            </td>
                            @if($status !== 'pending')
                                <td class="px-5 py-3.5">
                                    @if($report->action_taken)
                                        <span class="text-mob-muted text-xs capitalize">{{ $report->action_taken }}</span>
                                    @else
                                        <span class="text-mob-dim text-xs">&mdash;</span>
                                    @endif
                                </td>
                            @endif
                            <td class="px-5 py-3.5 text-mob-dim text-xs">
                                {{ $report->created_at->format('M j, Y') }}
                                <span class="block text-[10px] text-mob-dim/60">{{ $report->created_at->diffForHumans() }}</span>
                            </td>
                            <td class="px-5 py-3.5 text-right">
                                <a href="{{ route('admin.reports.show', $report) }}" class="text-mob-cyan hover:text-white text-xs font-medium transition-colors">
                                    Review
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="{{ $status !== 'pending' ? 7 : 6 }}" class="px-5 py-12 text-center">
                                <p class="text-mob-dim text-sm">
                                    @if($status === 'pending')
                                        No pending reports. All caught up!
                                    @elseif(request('search'))
                                        No reports matching "{{ request('search') }}".
                                    @else
                                        No {{ $status }} reports found.
                                    @endif
                                </p>
                                @if($status !== 'pending' || request('search') || request('reason'))
                                    <a href="{{ route('admin.reports.index') }}" class="text-mob-cyan text-sm hover:underline mt-1 inline-block">View pending reports</a>
                                @endif
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($reports->hasPages())
            <div class="px-5 py-4 border-t border-mob-border">
                {{ $reports->links() }}
            </div>
        @endif
    </div>
@endsection
