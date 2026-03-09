@extends('admin.layouts.app')

@section('title', 'Tickets')
@section('page-title', 'Ticket Management')
@section('page-subtitle', number_format($counts['total']) . ' total tickets')

@section('content')
    <!-- Stats Row -->
    <div class="grid grid-cols-2 md:grid-cols-5 gap-3 mb-6">
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Total Revenue</p>
            <p class="text-lg font-bold text-white">&#8358;{{ number_format($stats['total_revenue'], 2) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">From paid tickets</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Paid</p>
            <p class="text-lg font-bold text-mob-green">{{ number_format($counts['paid']) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Confirmed purchases</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Checked In</p>
            <p class="text-lg font-bold text-mob-cyan">{{ number_format($stats['checked_in']) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Attended events</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Refunded</p>
            <p class="text-lg font-bold text-mob-dim">{{ number_format($counts['refunded']) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">&#8358;{{ number_format($stats['refunded_amount'], 2) }} returned</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Pending</p>
            <p class="text-lg font-bold text-mob-amber">{{ number_format($counts['pending']) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Awaiting payment</p>
        </div>
    </div>

    <!-- Tab Pills -->
    <div class="flex flex-wrap items-center gap-2 mb-6">
        @php
            $tabs = [
                'all' => ['label' => 'All', 'count' => $counts['total'], 'color' => 'mob-cyan'],
                'paid' => ['label' => 'Paid', 'count' => $counts['paid'], 'color' => 'mob-green'],
                'pending' => ['label' => 'Pending', 'count' => $counts['pending'], 'color' => 'mob-amber'],
                'refund_processing' => ['label' => 'Processing Refund', 'count' => $counts['refund_processing'], 'color' => 'mob-red'],
                'refunded' => ['label' => 'Refunded', 'count' => $counts['refunded'], 'color' => 'mob-dim'],
            ];
        @endphp
        @foreach($tabs as $value => $tab)
            <a href="{{ route('admin.tickets.index', array_merge(request()->only(['search', 'gateway', 'checked_in']), $value === 'all' ? [] : ['status' => $value])) }}"
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
        <form method="GET" action="{{ route('admin.tickets.index') }}" class="flex flex-col sm:flex-row gap-3">
            @if($status !== 'all')
                <input type="hidden" name="status" value="{{ $status }}">
            @endif
            <div class="flex-1">
                <input
                    type="text"
                    name="search"
                    value="{{ request('search') }}"
                    placeholder="Search by ticket #, UUID, payment reference, or buyer name..."
                    class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none transition-colors"
                />
            </div>
            <div class="w-full sm:w-40">
                <select
                    name="gateway"
                    class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white focus:border-mob-cyan focus:outline-none transition-colors appearance-none"
                >
                    <option value="">All Gateways</option>
                    @foreach(\App\Enums\PaymentGateway::cases() as $gw)
                        <option value="{{ $gw->value }}" {{ request('gateway') === $gw->value ? 'selected' : '' }}>
                            {{ ucfirst($gw->value) }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="w-full sm:w-40">
                <select
                    name="checked_in"
                    class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white focus:border-mob-cyan focus:outline-none transition-colors appearance-none"
                >
                    <option value="">Check-in: Any</option>
                    <option value="yes" {{ request('checked_in') === 'yes' ? 'selected' : '' }}>Checked In</option>
                    <option value="no" {{ request('checked_in') === 'no' ? 'selected' : '' }}>Not Checked In</option>
                </select>
            </div>
            <button
                type="submit"
                class="px-5 py-2.5 bg-mob-cyan/10 text-mob-cyan text-sm font-medium rounded-lg hover:bg-mob-cyan/20 transition-colors cursor-pointer"
            >
                Search
            </button>
            @if(request('search') || request('gateway') || request('checked_in'))
                <a
                    href="{{ route('admin.tickets.index', $status !== 'all' ? ['status' => $status] : []) }}"
                    class="px-5 py-2.5 bg-mob-elevated text-mob-muted text-sm font-medium rounded-lg hover:text-white transition-colors text-center"
                >
                    Clear
                </a>
            @endif
        </form>
    </div>

    <!-- Tickets Table -->
    <div class="bg-mob-card border border-mob-border rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left">
                <thead>
                    <tr class="border-b border-mob-border">
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Ticket</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Buyer</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Event</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Qty</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Amount</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Gateway</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Status</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Check-in</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Date</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-mob-border">
                    @forelse($tickets as $ticket)
                        @php
                            $ticketStatusColors = [
                                'pending' => 'text-mob-amber bg-mob-amber/10',
                                'paid' => 'text-mob-green bg-mob-green/10',
                                'refunded' => 'text-mob-dim bg-mob-elevated',
                                'refund_processing' => 'text-mob-red bg-mob-red/10',
                            ];
                        @endphp
                        <tr class="hover:bg-mob-elevated/50 transition-colors">
                            <td class="px-5 py-3.5">
                                <a href="{{ route('admin.tickets.show', $ticket) }}" class="text-mob-cyan hover:text-white text-xs font-medium font-mono transition-colors">
                                    {{ $ticket->ticket_number ?? Str::limit($ticket->uuid, 12) }}
                                </a>
                            </td>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-2">
                                    <div class="w-6 h-6 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-[10px] font-bold shrink-0">
                                        {{ strtoupper(substr($ticket->user->name ?? '?', 0, 1)) }}
                                    </div>
                                    <span class="text-white text-sm truncate max-w-[120px]">{{ $ticket->user->name ?? 'Unknown' }}</span>
                                </div>
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="text-mob-muted text-sm truncate max-w-[160px] block">{{ $ticket->happening->title ?? 'Deleted Event' }}</span>
                            </td>
                            <td class="px-5 py-3.5 text-mob-muted text-sm">{{ $ticket->quantity }}</td>
                            <td class="px-5 py-3.5 text-white text-sm font-medium">&#8358;{{ number_format($ticket->amount, 2) }}</td>
                            <td class="px-5 py-3.5">
                                <span class="text-[10px] text-mob-muted uppercase font-medium">{{ $ticket->payment_gateway?->value ?? '--' }}</span>
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $ticketStatusColors[$ticket->status->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                    {{ str_replace('_', ' ', $ticket->status->value) }}
                                </span>
                            </td>
                            <td class="px-5 py-3.5">
                                @if($ticket->checked_in_at)
                                    <span class="inline-flex items-center gap-1 text-mob-green text-xs font-medium">
                                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                                        {{ $ticket->checked_in_at->format('g:i A') }}
                                    </span>
                                @else
                                    <span class="text-mob-dim text-xs">&mdash;</span>
                                @endif
                            </td>
                            <td class="px-5 py-3.5 text-mob-dim text-xs">
                                {{ $ticket->paid_at?->format('M j, Y') ?? $ticket->created_at->format('M j, Y') }}
                            </td>
                            <td class="px-5 py-3.5 text-right">
                                <a href="{{ route('admin.tickets.show', $ticket) }}" class="text-mob-cyan hover:text-white text-xs font-medium transition-colors">
                                    View
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="10" class="px-5 py-12 text-center">
                                <p class="text-mob-dim text-sm">
                                    @if(request('search'))
                                        No tickets matching "{{ request('search') }}".
                                    @elseif($status !== 'all')
                                        No {{ str_replace('_', ' ', $status) }} tickets found.
                                    @else
                                        No tickets found.
                                    @endif
                                </p>
                                @if(request('search') || request('gateway') || request('checked_in') || $status !== 'all')
                                    <a href="{{ route('admin.tickets.index') }}" class="text-mob-cyan text-sm hover:underline mt-1 inline-block">Clear all filters</a>
                                @endif
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($tickets->hasPages())
            <div class="px-5 py-4 border-t border-mob-border">
                {{ $tickets->links() }}
            </div>
        @endif
    </div>
@endsection
