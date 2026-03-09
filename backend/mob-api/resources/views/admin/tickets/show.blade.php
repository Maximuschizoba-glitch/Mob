@extends('admin.layouts.app')

@section('title', 'Ticket: ' . ($ticket->ticket_number ?? Str::limit($ticket->uuid, 12)))
@section('page-title', 'Ticket Detail')
@section('page-subtitle', $ticket->ticket_number ?? 'No ticket number')

@section('content')
    <!-- Back Link -->
    <div class="mb-6">
        <a href="{{ route('admin.tickets.index') }}" class="text-mob-dim hover:text-mob-cyan text-sm transition-colors inline-flex items-center gap-1.5">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Tickets
        </a>
    </div>

    @php
        $statusColors = [
            'pending' => 'text-mob-amber bg-mob-amber/10 border-mob-amber/20',
            'paid' => 'text-mob-green bg-mob-green/10 border-mob-green/20',
            'refunded' => 'text-mob-dim bg-mob-elevated border-mob-border',
            'refund_processing' => 'text-mob-red bg-mob-red/10 border-mob-red/20',
        ];
        $currentStatusClass = $statusColors[$ticket->status->value] ?? 'text-mob-dim bg-mob-elevated border-mob-border';
    @endphp

    <!-- Status Banner -->
    @if($ticket->status === \App\Enums\TicketStatus::REFUNDED)
        <div class="mb-6 bg-mob-elevated border border-mob-border rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-dim shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"/></svg>
                <div class="flex-1">
                    <p class="text-mob-muted font-semibold text-sm">Refunded</p>
                    @if($ticket->refunded_at)
                        <p class="text-mob-dim text-xs mt-0.5">Refunded on {{ $ticket->refunded_at->format('M j, Y \a\t g:i A') }}</p>
                    @endif
                    <p class="text-mob-dim text-xs mt-0.5">&#8358;{{ number_format($ticket->amount, 2) }} returned to buyer</p>
                </div>
            </div>
        </div>
    @elseif($ticket->status === \App\Enums\TicketStatus::REFUND_PROCESSING)
        <div class="mb-6 bg-mob-red/10 border border-mob-red/20 rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-red shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <div class="flex-1">
                    <p class="text-mob-red font-semibold text-sm">Refund Processing</p>
                    <p class="text-mob-red/70 text-xs mt-0.5">Refund of &#8358;{{ number_format($ticket->amount, 2) }} is being processed via {{ ucfirst($ticket->payment_gateway?->value ?? 'gateway') }}</p>
                </div>
            </div>
        </div>
    @elseif($ticket->checked_in_at)
        <div class="mb-6 bg-mob-green/10 border border-mob-green/20 rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-green shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <div class="flex-1">
                    <p class="text-mob-green font-semibold text-sm">Checked In</p>
                    <p class="text-mob-green/70 text-xs mt-0.5">Checked in on {{ $ticket->checked_in_at->format('M j, Y \a\t g:i A') }}</p>
                </div>
            </div>
        </div>
    @endif

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h2 class="text-xl font-bold text-white">
                @if($ticket->ticket_number)
                    Ticket #{{ $ticket->ticket_number }}
                @else
                    Ticket
                @endif
            </h2>
            <p class="text-mob-dim text-xs mt-1 font-mono">{{ $ticket->uuid }}</p>
        </div>
        <span class="inline-block px-3 py-1.5 rounded-lg text-xs font-medium uppercase border {{ $currentStatusClass }} self-start sm:self-auto">
            {{ str_replace('_', ' ', $ticket->status->value) }}
        </span>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Amount</p>
            <p class="text-xl font-bold text-white">&#8358;{{ number_format($ticket->amount, 2) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">{{ strtoupper($ticket->currency) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Quantity</p>
            <p class="text-xl font-bold text-mob-cyan">{{ $ticket->quantity }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">{{ Str::plural('ticket', $ticket->quantity) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Gateway</p>
            <p class="text-xl font-bold text-mob-purple capitalize">{{ $ticket->payment_gateway?->value ?? '--' }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Check-in</p>
            @if($ticket->checked_in_at)
                <p class="text-xl font-bold text-mob-green">Yes</p>
                <p class="text-mob-dim text-[10px] mt-0.5">{{ $ticket->checked_in_at->format('g:i A') }}</p>
            @else
                <p class="text-xl font-bold text-mob-dim">No</p>
                <p class="text-mob-dim text-[10px] mt-0.5">Not checked in</p>
            @endif
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Left Column -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Payment Details -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Payment Details</h3>
                </div>
                <div class="divide-y divide-mob-border">
                    <div class="flex items-center justify-between px-5 py-3">
                        <span class="text-xs text-mob-dim uppercase tracking-wider">Payment Reference</span>
                        <span class="text-sm text-white font-mono">{{ $ticket->payment_reference ?? '--' }}</span>
                    </div>
                    <div class="flex items-center justify-between px-5 py-3">
                        <span class="text-xs text-mob-dim uppercase tracking-wider">Gateway</span>
                        <span class="text-sm text-white capitalize font-medium">{{ $ticket->payment_gateway?->value ?? '--' }}</span>
                    </div>
                    <div class="flex items-center justify-between px-5 py-3">
                        <span class="text-xs text-mob-dim uppercase tracking-wider">Amount</span>
                        <span class="text-sm text-white font-medium">&#8358;{{ number_format($ticket->amount, 2) }}</span>
                    </div>
                    <div class="flex items-center justify-between px-5 py-3">
                        <span class="text-xs text-mob-dim uppercase tracking-wider">Currency</span>
                        <span class="text-sm text-white">{{ strtoupper($ticket->currency) }}</span>
                    </div>
                    <div class="flex items-center justify-between px-5 py-3">
                        <span class="text-xs text-mob-dim uppercase tracking-wider">Quantity</span>
                        <span class="text-sm text-white">{{ $ticket->quantity }}</span>
                    </div>
                    <div class="flex items-center justify-between px-5 py-3">
                        <span class="text-xs text-mob-dim uppercase tracking-wider">Status</span>
                        @php
                            $inlineStatusColors = [
                                'pending' => 'text-mob-amber bg-mob-amber/10',
                                'paid' => 'text-mob-green bg-mob-green/10',
                                'refunded' => 'text-mob-dim bg-mob-elevated',
                                'refund_processing' => 'text-mob-red bg-mob-red/10',
                            ];
                        @endphp
                        <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $inlineStatusColors[$ticket->status->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                            {{ str_replace('_', ' ', $ticket->status->value) }}
                        </span>
                    </div>
                </div>
            </div>

            <!-- Timeline -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Ticket Timeline</h3>
                </div>
                <div class="p-5">
                    @php
                        $steps = [
                            ['label' => 'Ticket Created', 'date' => $ticket->created_at, 'color' => 'mob-cyan'],
                            ['label' => 'Payment Confirmed', 'date' => $ticket->paid_at, 'color' => 'mob-green'],
                        ];
                        // Only show check-in step for paid tickets
                        if ($ticket->status === \App\Enums\TicketStatus::PAID || $ticket->checked_in_at) {
                            $steps[] = ['label' => 'Checked In at Event', 'date' => $ticket->checked_in_at, 'color' => 'mob-green'];
                        }
                        // Show refund steps if applicable
                        if ($ticket->status === \App\Enums\TicketStatus::REFUND_PROCESSING) {
                            $steps[] = ['label' => 'Refund Processing', 'date' => $ticket->updated_at, 'color' => 'mob-red'];
                        }
                        if ($ticket->refunded_at) {
                            $steps[] = ['label' => 'Refund Completed', 'date' => $ticket->refunded_at, 'color' => 'mob-red'];
                        }
                    @endphp
                    <div class="space-y-0">
                        @foreach($steps as $i => $step)
                            <div class="flex items-start gap-3 relative {{ !$loop->last ? 'pb-6' : '' }}">
                                @if(!$loop->last)
                                    <div class="absolute left-[9px] top-5 bottom-0 w-0.5 {{ $step['date'] ? 'bg-' . $step['color'] . '/30' : 'bg-mob-border' }}"></div>
                                @endif
                                <div class="w-5 h-5 rounded-full flex items-center justify-center shrink-0 z-10
                                    {{ $step['date'] ? 'bg-' . $step['color'] . '/20' : 'bg-mob-elevated' }}">
                                    @if($step['date'])
                                        <div class="w-2.5 h-2.5 rounded-full bg-{{ $step['color'] }}"></div>
                                    @else
                                        <div class="w-2.5 h-2.5 rounded-full bg-mob-border"></div>
                                    @endif
                                </div>
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm font-medium {{ $step['date'] ? 'text-white' : 'text-mob-dim' }}">{{ $step['label'] }}</p>
                                    <p class="text-xs {{ $step['date'] ? 'text-mob-muted' : 'text-mob-dim' }}">
                                        {{ $step['date'] ? $step['date']->format('M j, Y \a\t g:i A') : 'Pending' }}
                                    </p>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>

            <!-- Escrow Status Snapshot -->
            @if($ticket->escrow_status_snapshot)
                <div class="bg-mob-card border border-mob-border rounded-xl p-5">
                    <p class="text-mob-dim text-xs uppercase tracking-wider mb-2">Escrow Status (Buyer View)</p>
                    @php
                        $snapshotColors = [
                            'collecting' => 'text-mob-cyan',
                            'held' => 'text-mob-amber',
                            'awaiting_completion' => 'text-mob-purple',
                            'released' => 'text-mob-green',
                            'refunding' => 'text-mob-red',
                            'refunded' => 'text-mob-dim',
                        ];
                    @endphp
                    <p class="text-sm font-medium {{ $snapshotColors[$ticket->escrow_status_snapshot] ?? 'text-mob-dim' }} uppercase">
                        {{ str_replace('_', ' ', $ticket->escrow_status_snapshot) }}
                    </p>
                    <p class="text-mob-dim text-xs mt-1">This is the cached escrow status visible to the buyer on their ticket.</p>
                </div>
            @endif
        </div>

        <!-- Right Column: Sidebar -->
        <div class="space-y-6">
            <!-- Buyer Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Buyer</h3>
                </div>
                <div class="p-5">
                    @if($ticket->user)
                        <a href="{{ route('admin.users.show', $ticket->user) }}" class="flex items-center gap-3 group">
                            <div class="w-10 h-10 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-sm font-bold shrink-0">
                                {{ strtoupper(substr($ticket->user->name, 0, 1)) }}
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm text-white group-hover:text-mob-cyan transition-colors font-medium truncate">{{ $ticket->user->name }}</p>
                                <p class="text-xs text-mob-dim truncate">{{ $ticket->user->email }}</p>
                            </div>
                        </a>
                        @if($ticket->user->phone)
                            <div class="mt-3 pt-3 border-t border-mob-border">
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-mob-dim">Phone</span>
                                    <span class="text-mob-muted">{{ $ticket->user->phone }}</span>
                                </div>
                            </div>
                        @endif
                    @else
                        <p class="text-mob-dim text-sm">Buyer not found.</p>
                    @endif
                </div>
            </div>

            <!-- Event Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Event</h3>
                </div>
                <div class="p-5">
                    @if($ticket->happening)
                        <p class="text-white text-sm font-medium mb-2">{{ $ticket->happening->title }}</p>
                        <div class="space-y-2">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Status</span>
                                @php
                                    $hapStatusColors = [
                                        'active' => 'text-mob-green',
                                        'completed' => 'text-mob-dim',
                                        'expired' => 'text-mob-dim',
                                        'hidden' => 'text-mob-red',
                                        'reported' => 'text-mob-red',
                                    ];
                                @endphp
                                <span class="{{ $hapStatusColors[$ticket->happening->status->value] ?? 'text-mob-dim' }} uppercase font-medium">{{ $ticket->happening->status->value }}</span>
                            </div>
                            @if($ticket->happening->starts_at)
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-mob-dim">Date</span>
                                    <span class="text-mob-muted">{{ $ticket->happening->starts_at->format('M j, Y') }}</span>
                                </div>
                            @endif
                            @if($ticket->happening->ticket_price)
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-mob-dim">Ticket Price</span>
                                    <span class="text-white font-medium">&#8358;{{ number_format($ticket->happening->ticket_price, 2) }}</span>
                                </div>
                            @endif
                        </div>
                        <div class="mt-3 pt-3 border-t border-mob-border">
                            <a href="{{ route('admin.happenings.show', $ticket->happening) }}" class="text-mob-cyan text-xs font-medium hover:underline">
                                View Event Details &rarr;
                            </a>
                        </div>
                    @else
                        <p class="text-mob-dim text-sm">Event has been deleted.</p>
                    @endif
                </div>
            </div>

            <!-- Escrow Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Escrow</h3>
                </div>
                <div class="p-5">
                    @if($ticket->escrow)
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
                        <div class="space-y-3">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Status</span>
                                <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $escrowStatusColors[$ticket->escrow->status->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                    {{ str_replace('_', ' ', $ticket->escrow->status->value) }}
                                </span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Total Held</span>
                                <span class="text-white font-medium">&#8358;{{ number_format($ticket->escrow->total_amount, 2) }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Tickets</span>
                                <span class="text-mob-muted">{{ $ticket->escrow->tickets_count }}</span>
                            </div>
                        </div>
                        <div class="mt-3 pt-3 border-t border-mob-border">
                            <a href="{{ route('admin.escrow.show', $ticket->escrow) }}" class="text-mob-cyan text-xs font-medium hover:underline">
                                View Escrow Details &rarr;
                            </a>
                        </div>
                    @else
                        <p class="text-mob-dim text-sm">No escrow record linked.</p>
                    @endif
                </div>
            </div>

            <!-- Quick Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Details</h3>
                </div>
                <div class="p-5 space-y-3">
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Ticket ID</span>
                        <span class="text-mob-muted">#{{ $ticket->id }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">UUID</span>
                        <span class="text-mob-muted font-mono text-[10px]">{{ Str::limit($ticket->uuid, 16) }}</span>
                    </div>
                    @if($ticket->ticket_number)
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-mob-dim">Ticket Number</span>
                            <span class="text-mob-cyan font-mono font-medium">{{ $ticket->ticket_number }}</span>
                        </div>
                    @endif
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Created</span>
                        <span class="text-mob-muted">{{ $ticket->created_at->format('M j, Y g:i A') }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Last Updated</span>
                        <span class="text-mob-muted">{{ $ticket->updated_at->format('M j, Y g:i A') }}</span>
                    </div>
                    @if($ticket->paid_at)
                        <div class="flex items-center justify-between text-xs pt-2 border-t border-mob-border">
                            <span class="text-mob-dim">Paid</span>
                            <span class="text-mob-green font-medium">{{ $ticket->paid_at->diffForHumans() }}</span>
                        </div>
                    @endif
                    @if($ticket->checked_in_at)
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-mob-dim">Checked in</span>
                            <span class="text-mob-cyan font-medium">{{ $ticket->checked_in_at->diffForHumans() }}</span>
                        </div>
                    @endif
                    @if($ticket->refunded_at)
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-mob-dim">Refunded</span>
                            <span class="text-mob-dim font-medium">{{ $ticket->refunded_at->diffForHumans() }}</span>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
