@extends('admin.layouts.app')

@section('title', 'Escrow Management')
@section('page-title', 'Escrow Management')
@section('page-subtitle', $counts['awaiting_completion'] . ' awaiting release')

@section('content')
    <!-- Financial Summary -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Funds Held</p>
            <p class="text-lg font-bold text-white">&#8358;{{ number_format($financials['total_held'], 2) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Collecting + Held + Awaiting</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Awaiting Release</p>
            <p class="text-lg font-bold text-mob-purple">&#8358;{{ number_format($financials['awaiting_release'], 2) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Host payouts pending approval</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Total Released</p>
            <p class="text-lg font-bold text-mob-green">&#8358;{{ number_format($financials['total_released'], 2) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Paid out to hosts</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Platform Fees Earned</p>
            <p class="text-lg font-bold text-mob-cyan">&#8358;{{ number_format($financials['total_fees_earned'], 2) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">From released escrows</p>
        </div>
    </div>

    <!-- Tab Pills -->
    <div class="flex flex-wrap items-center gap-2 mb-6">
        @php
            $tabs = [
                'awaiting_completion' => ['label' => 'Awaiting Release', 'count' => $counts['awaiting_completion'], 'color' => 'mob-purple'],
                'collecting' => ['label' => 'Collecting', 'count' => $counts['collecting'], 'color' => 'mob-cyan'],
                'held' => ['label' => 'Held', 'count' => $counts['held'], 'color' => 'mob-amber'],
                'released' => ['label' => 'Released', 'count' => $counts['released'], 'color' => 'mob-green'],
                'refunding' => ['label' => 'Refunding', 'count' => $counts['refunding'], 'color' => 'mob-red'],
                'refunded' => ['label' => 'Refunded', 'count' => $counts['refunded'], 'color' => 'mob-dim'],
                'all' => ['label' => 'All', 'count' => $counts['total'], 'color' => 'mob-cyan'],
            ];
        @endphp
        @foreach($tabs as $value => $tab)
            <a href="{{ route('admin.escrow.index', $value === 'awaiting_completion' ? [] : ['status' => $value]) }}"
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

    <!-- Escrow Table -->
    <div class="bg-mob-card border border-mob-border rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left">
                <thead>
                    <tr class="border-b border-mob-border">
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Event</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Host</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Tickets</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Total</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Fee</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Host Payout</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Status</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">
                            {{ $status === 'awaiting_completion' ? 'Completed' : 'Created' }}
                        </th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-mob-border">
                    @forelse($escrows as $escrow)
                        @php
                            $escrowStatusColors = [
                                'collecting' => 'text-mob-cyan bg-mob-cyan/10',
                                'held' => 'text-mob-amber bg-mob-amber/10',
                                'awaiting_completion' => 'text-mob-purple bg-mob-purple/10',
                                'released' => 'text-mob-green bg-mob-green/10',
                                'refunding' => 'text-mob-red bg-mob-red/10',
                                'refunded' => 'text-mob-dim bg-mob-elevated',
                                'disputed' => 'text-mob-red bg-mob-red/10',
                            ];
                        @endphp
                        <tr class="hover:bg-mob-elevated/50 transition-colors">
                            <td class="px-5 py-3.5">
                                <a href="{{ route('admin.escrow.show', $escrow) }}" class="text-white hover:text-mob-cyan text-sm font-medium transition-colors truncate block max-w-[200px]">
                                    {{ $escrow->happening->title ?? 'Deleted Event' }}
                                </a>
                            </td>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-2">
                                    <div class="w-6 h-6 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-[10px] font-bold shrink-0">
                                        {{ strtoupper(substr($escrow->host->name ?? '?', 0, 1)) }}
                                    </div>
                                    <span class="text-mob-muted text-sm truncate max-w-[100px]">{{ $escrow->host->name ?? 'Unknown' }}</span>
                                </div>
                            </td>
                            <td class="px-5 py-3.5 text-mob-muted text-sm">{{ $escrow->tickets_count }}</td>
                            <td class="px-5 py-3.5 text-white text-sm font-medium">&#8358;{{ number_format($escrow->total_amount, 2) }}</td>
                            <td class="px-5 py-3.5 text-mob-amber text-xs">&#8358;{{ number_format($escrow->platform_fee, 2) }}</td>
                            <td class="px-5 py-3.5 text-mob-green text-sm font-medium">&#8358;{{ number_format($escrow->host_payout_amount, 2) }}</td>
                            <td class="px-5 py-3.5">
                                <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $escrowStatusColors[$escrow->status->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                    {{ str_replace('_', ' ', $escrow->status->value) }}
                                </span>
                            </td>
                            <td class="px-5 py-3.5 text-mob-dim text-xs">
                                @if($status === 'awaiting_completion' && $escrow->host_completed_at)
                                    {{ $escrow->host_completed_at->format('M j, Y') }}
                                @else
                                    {{ $escrow->created_at->format('M j, Y') }}
                                @endif
                            </td>
                            <td class="px-5 py-3.5 text-right">
                                <a href="{{ route('admin.escrow.show', $escrow) }}" class="text-mob-cyan hover:text-white text-xs font-medium transition-colors">
                                    Review
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="9" class="px-5 py-12 text-center">
                                <p class="text-mob-dim text-sm">
                                    @if($status === 'awaiting_completion')
                                        No escrows awaiting release. All caught up!
                                    @else
                                        No escrow records found.
                                    @endif
                                </p>
                                @if($status !== 'awaiting_completion')
                                    <a href="{{ route('admin.escrow.index') }}" class="text-mob-cyan text-sm hover:underline mt-1 inline-block">View awaiting release</a>
                                @endif
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($escrows->hasPages())
            <div class="px-5 py-4 border-t border-mob-border">
                {{ $escrows->links() }}
            </div>
        @endif
    </div>
@endsection
