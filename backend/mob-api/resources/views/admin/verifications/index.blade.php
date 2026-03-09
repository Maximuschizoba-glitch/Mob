@extends('admin.layouts.app')

@section('title', 'Host Verifications')
@section('page-title', 'Host Verifications')
@section('page-subtitle', $counts['pending'] . ' pending review')

@section('content')
    <!-- Stats Row -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Total</p>
            <p class="text-lg font-bold text-white">{{ number_format($counts['total']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Pending</p>
            <p class="text-lg font-bold text-mob-amber">{{ number_format($counts['pending']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Approved</p>
            <p class="text-lg font-bold text-mob-green">{{ number_format($counts['approved']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Rejected</p>
            <p class="text-lg font-bold text-mob-red">{{ number_format($counts['rejected']) }}</p>
        </div>
    </div>

    <!-- Tab Pills -->
    <div class="flex items-center gap-2 mb-6">
        @php
            $tabs = [
                'pending' => ['label' => 'Pending', 'count' => $counts['pending'], 'color' => 'mob-amber'],
                'approved' => ['label' => 'Approved', 'count' => $counts['approved'], 'color' => 'mob-green'],
                'rejected' => ['label' => 'Rejected', 'count' => $counts['rejected'], 'color' => 'mob-red'],
                'all' => ['label' => 'All', 'count' => $counts['total'], 'color' => 'mob-cyan'],
            ];
        @endphp
        @foreach($tabs as $value => $tab)
            <a href="{{ route('admin.verifications.index', $value === 'pending' ? [] : ['status' => $value]) }}"
               class="px-4 py-2 text-sm font-medium rounded-lg transition-colors inline-flex items-center gap-2
                   {{ $status === $value
                       ? 'bg-mob-cyan/10 text-mob-cyan border border-mob-cyan/30'
                       : 'bg-mob-card text-mob-muted border border-mob-border hover:text-white hover:border-mob-border' }}">
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

    <!-- Verifications Table -->
    <div class="bg-mob-card border border-mob-border rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left">
                <thead>
                    <tr class="border-b border-mob-border">
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Applicant</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Business</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Document</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Host Type</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Status</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Submitted</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-mob-border">
                    @forelse($verifications as $verification)
                        <tr class="hover:bg-mob-elevated/50 transition-colors">
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-mob-elevated flex items-center justify-center text-mob-purple text-sm font-bold shrink-0">
                                        {{ strtoupper(substr($verification->user->name ?? '?', 0, 1)) }}
                                    </div>
                                    <div class="min-w-0">
                                        <p class="text-white text-sm font-medium truncate max-w-[180px]">{{ $verification->user->name ?? 'Unknown' }}</p>
                                        <p class="text-mob-dim text-xs truncate max-w-[180px]">{{ $verification->user->email ?? '--' }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-3.5 text-mob-muted text-sm">
                                {{ $verification->business_name ?? '--' }}
                            </td>
                            <td class="px-5 py-3.5">
                                @if($verification->verification_document_type)
                                    <span class="inline-block px-2 py-0.5 rounded text-xs font-medium uppercase bg-mob-elevated text-mob-muted tracking-wide">
                                        {{ $verification->verification_document_type }}
                                    </span>
                                @else
                                    <span class="text-mob-dim text-xs">--</span>
                                @endif
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="text-mob-muted text-xs capitalize">{{ $verification->host_type->value }}</span>
                            </td>
                            <td class="px-5 py-3.5">
                                @php
                                    $statusColors = [
                                        'pending' => 'text-mob-amber bg-mob-amber/10',
                                        'approved' => 'text-mob-green bg-mob-green/10',
                                        'rejected' => 'text-mob-red bg-mob-red/10',
                                    ];
                                    $statusClass = $statusColors[$verification->verification_status->value] ?? 'text-mob-dim bg-mob-elevated';
                                @endphp
                                <span class="inline-block px-2 py-0.5 rounded text-xs font-medium uppercase {{ $statusClass }}">
                                    {{ $verification->verification_status->value }}
                                </span>
                            </td>
                            <td class="px-5 py-3.5 text-mob-dim text-xs">
                                {{ $verification->created_at->format('M j, Y') }}
                            </td>
                            <td class="px-5 py-3.5 text-right">
                                <a href="{{ route('admin.verifications.show', $verification) }}" class="text-mob-cyan hover:text-white text-xs font-medium transition-colors">
                                    Review
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="px-5 py-12 text-center">
                                <p class="text-mob-dim text-sm">
                                    @if($status === 'pending')
                                        No pending verifications. All caught up!
                                    @elseif($status === 'approved')
                                        No approved verifications yet.
                                    @elseif($status === 'rejected')
                                        No rejected verifications.
                                    @else
                                        No verification requests found.
                                    @endif
                                </p>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($verifications->hasPages())
            <div class="px-5 py-4 border-t border-mob-border">
                {{ $verifications->links() }}
            </div>
        @endif
    </div>
@endsection
