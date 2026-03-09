@extends('admin.layouts.app')

@section('title', 'Escrow: ' . ($escrow->happening->title ?? 'Unknown'))
@section('page-title', 'Escrow Review')
@section('page-subtitle', 'UUID: ' . Str::limit($escrow->uuid, 12))

@section('content')
    <!-- Back Link -->
    <div class="mb-6">
        <a href="{{ route('admin.escrow.index') }}" class="text-mob-dim hover:text-mob-cyan text-sm transition-colors inline-flex items-center gap-1.5">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Escrow Management
        </a>
    </div>

    @php
        $escrowStatusColors = [
            'collecting' => 'text-mob-cyan bg-mob-cyan/10 border-mob-cyan/20',
            'held' => 'text-mob-amber bg-mob-amber/10 border-mob-amber/20',
            'awaiting_completion' => 'text-mob-purple bg-mob-purple/10 border-mob-purple/20',
            'released' => 'text-mob-green bg-mob-green/10 border-mob-green/20',
            'refunding' => 'text-mob-red bg-mob-red/10 border-mob-red/20',
            'refunded' => 'text-mob-dim bg-mob-elevated border-mob-border',
            'disputed' => 'text-mob-red bg-mob-red/10 border-mob-red/20',
        ];
        $currentStatusClass = $escrowStatusColors[$escrow->status->value] ?? 'text-mob-dim bg-mob-elevated border-mob-border';
    @endphp

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h2 class="text-xl font-bold text-white">{{ $escrow->happening->title ?? 'Deleted Event' }}</h2>
            <p class="text-mob-dim text-xs mt-1 font-mono">{{ $escrow->uuid }}</p>
        </div>
        <span class="inline-block px-3 py-1.5 rounded-lg text-xs font-medium uppercase border {{ $currentStatusClass }} self-start sm:self-auto">
            {{ str_replace('_', ' ', $escrow->status->value) }}
        </span>
    </div>

    <!-- Financial Summary Cards -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Total Revenue</p>
            <p class="text-xl font-bold text-white">&#8358;{{ number_format($escrow->total_amount, 2) }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">{{ $escrow->tickets_count }} {{ Str::plural('ticket', $escrow->tickets_count) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Platform Fee (10%)</p>
            <p class="text-xl font-bold text-mob-amber">&#8358;{{ number_format($escrow->platform_fee, 2) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Host Payout</p>
            <p class="text-xl font-bold text-mob-green">&#8358;{{ number_format($escrow->host_payout_amount, 2) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Ticket Breakdown</p>
            <div class="flex items-center gap-2 mt-1">
                <span class="text-mob-green text-xs font-medium">{{ $ticketBreakdown['paid'] }} paid</span>
                @if($ticketBreakdown['checked_in'] > 0)
                    <span class="text-mob-cyan text-xs">{{ $ticketBreakdown['checked_in'] }} checked in</span>
                @endif
                @if($ticketBreakdown['refunded'] > 0)
                    <span class="text-mob-dim text-xs">{{ $ticketBreakdown['refunded'] }} refunded</span>
                @endif
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Left Column -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Status Timeline -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Escrow Timeline</h3>
                </div>
                <div class="p-5">
                    @php
                        $steps = [
                            ['label' => 'Escrow Created', 'date' => $escrow->created_at, 'icon' => 'plus', 'color' => 'mob-cyan'],
                            ['label' => 'Host Marked Complete', 'date' => $escrow->host_completed_at, 'icon' => 'check', 'color' => 'mob-purple'],
                            ['label' => 'Admin Approved', 'date' => $escrow->admin_approved_at, 'icon' => 'shield', 'color' => 'mob-green'],
                            ['label' => 'Funds Released', 'date' => $escrow->released_at, 'icon' => 'cash', 'color' => 'mob-green'],
                        ];
                        // Add refund steps if applicable
                        if ($escrow->refund_initiated_at) {
                            $steps[] = ['label' => 'Refund Initiated', 'date' => $escrow->refund_initiated_at, 'icon' => 'reverse', 'color' => 'mob-red'];
                        }
                        if ($escrow->refund_completed_at) {
                            $steps[] = ['label' => 'Refund Completed', 'date' => $escrow->refund_completed_at, 'icon' => 'check', 'color' => 'mob-red'];
                        }
                    @endphp
                    <div class="space-y-0">
                        @foreach($steps as $i => $step)
                            <div class="flex items-start gap-3 relative {{ !$loop->last ? 'pb-6' : '' }}">
                                {{-- Vertical connector line --}}
                                @if(!$loop->last)
                                    <div class="absolute left-[9px] top-5 bottom-0 w-0.5 {{ $step['date'] ? 'bg-' . $step['color'] . '/30' : 'bg-mob-border' }}"></div>
                                @endif
                                {{-- Dot --}}
                                <div class="w-5 h-5 rounded-full flex items-center justify-center shrink-0 z-10
                                    {{ $step['date'] ? 'bg-' . $step['color'] . '/20' : 'bg-mob-elevated' }}">
                                    @if($step['date'])
                                        <div class="w-2.5 h-2.5 rounded-full bg-{{ $step['color'] }}"></div>
                                    @else
                                        <div class="w-2.5 h-2.5 rounded-full bg-mob-border"></div>
                                    @endif
                                </div>
                                {{-- Content --}}
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

            <!-- Action Forms -->
            @if(in_array($escrow->status, [\App\Enums\EscrowStatus::AWAITING_COMPLETION, \App\Enums\EscrowStatus::COLLECTING, \App\Enums\EscrowStatus::HELD]))
                <div class="bg-mob-card border border-mob-border rounded-xl">
                    <div class="px-5 py-4 border-b border-mob-border">
                        <h3 class="text-sm font-semibold text-white">Admin Actions</h3>
                    </div>
                    <div class="p-5">
                        @if($escrow->status === \App\Enums\EscrowStatus::AWAITING_COMPLETION)
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                <!-- Approve / Release Payout -->
                                <div class="p-4 border border-mob-green/20 rounded-xl bg-mob-green/5">
                                    <h4 class="text-mob-green text-sm font-semibold mb-3">Release Payout</h4>
                                    <div class="mb-3 p-3 bg-mob-elevated rounded-lg">
                                        <div class="flex justify-between text-xs mb-1">
                                            <span class="text-mob-dim">Host receives</span>
                                            <span class="text-mob-green font-bold">&#8358;{{ number_format($escrow->host_payout_amount, 2) }}</span>
                                        </div>
                                        <div class="flex justify-between text-xs">
                                            <span class="text-mob-dim">Platform keeps</span>
                                            <span class="text-mob-amber font-medium">&#8358;{{ number_format($escrow->platform_fee, 2) }}</span>
                                        </div>
                                    </div>
                                    <form method="POST" action="{{ route('admin.escrow.approve', $escrow) }}">
                                        @csrf
                                        <textarea
                                            name="admin_notes"
                                            rows="2"
                                            placeholder="Approval notes (optional)..."
                                            class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-green focus:outline-none resize-none mb-3"
                                        ></textarea>
                                        <button type="submit"
                                                class="w-full px-4 py-2.5 text-sm font-medium rounded-lg bg-mob-green/15 text-mob-green hover:bg-mob-green/25 transition-colors cursor-pointer"
                                                onclick="return confirm('Release ₦{{ number_format($escrow->host_payout_amount, 2) }} to {{ $escrow->host->name ?? 'host' }}? This will queue the payout.')">
                                            Approve &amp; Release Payout
                                        </button>
                                    </form>
                                </div>

                                <!-- Reject / Refund -->
                                <div class="p-4 border border-mob-red/20 rounded-xl bg-mob-red/5">
                                    <h4 class="text-mob-red text-sm font-semibold mb-3">Reject &amp; Refund</h4>
                                    <p class="text-mob-dim text-xs mb-3">Event didn't happen or was fraudulent. All {{ $escrow->tickets_count }} ticket holders will be refunded.</p>
                                    <form method="POST" action="{{ route('admin.escrow.reject', $escrow) }}">
                                        @csrf
                                        <textarea
                                            name="admin_notes"
                                            rows="2"
                                            required
                                            placeholder="Rejection reason (required)..."
                                            class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-red focus:outline-none resize-none mb-3"
                                        ></textarea>
                                        @error('admin_notes')
                                            <p class="text-mob-red text-xs mb-2">{{ $message }}</p>
                                        @enderror
                                        <button type="submit"
                                                class="w-full px-4 py-2.5 text-sm font-medium rounded-lg bg-mob-red/15 text-mob-red hover:bg-mob-red/25 transition-colors cursor-pointer"
                                                onclick="return confirm('Reject this escrow and refund all {{ $escrow->tickets_count }} tickets? This cannot be undone.')">
                                            Reject &amp; Refund All
                                        </button>
                                    </form>
                                </div>
                            </div>
                        @endif

                        @if(in_array($escrow->status, [\App\Enums\EscrowStatus::COLLECTING, \App\Enums\EscrowStatus::HELD]))
                            <div class="p-4 border border-mob-red/20 rounded-xl bg-mob-red/5">
                                <h4 class="text-mob-red text-sm font-semibold mb-2">Force Refund</h4>
                                <p class="text-mob-dim text-xs mb-3">Override: Force refund all {{ $escrow->tickets_count }} tickets (&#8358;{{ number_format($escrow->total_amount, 2) }}). Use for emergencies or event cancellation.</p>
                                <form method="POST" action="{{ route('admin.escrow.refund', $escrow) }}">
                                    @csrf
                                    <textarea
                                        name="admin_notes"
                                        rows="2"
                                        required
                                        placeholder="Reason for force refund (required)..."
                                        class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-red focus:outline-none resize-none mb-3"
                                    ></textarea>
                                    @error('admin_notes')
                                        <p class="text-mob-red text-xs mb-2">{{ $message }}</p>
                                    @enderror
                                    <button type="submit"
                                            class="w-full px-4 py-2.5 text-sm font-medium rounded-lg bg-mob-red/15 text-mob-red hover:bg-mob-red/25 transition-colors cursor-pointer"
                                            onclick="return confirm('FORCE REFUND: Refund all {{ $escrow->tickets_count }} tickets totaling ₦{{ number_format($escrow->total_amount, 2) }}? This cannot be undone.')">
                                        Force Refund All Tickets
                                    </button>
                                </form>
                            </div>
                        @endif
                    </div>
                </div>
            @endif

            <!-- Admin Notes (for completed actions) -->
            @if($escrow->admin_notes && !in_array($escrow->status, [\App\Enums\EscrowStatus::AWAITING_COMPLETION, \App\Enums\EscrowStatus::COLLECTING, \App\Enums\EscrowStatus::HELD]))
                <div class="bg-mob-card border border-mob-border rounded-xl p-5">
                    <p class="text-mob-dim text-xs uppercase tracking-wider mb-2">Admin Notes</p>
                    <p class="text-mob-muted text-sm">{{ $escrow->admin_notes }}</p>
                </div>
            @endif

            <!-- Payout Info -->
            @if($escrow->payout)
                <div class="bg-mob-card border border-mob-border rounded-xl">
                    <div class="px-5 py-4 border-b border-mob-border">
                        <h3 class="text-sm font-semibold text-white">Payout Record</h3>
                    </div>
                    <div class="p-5">
                        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 text-sm">
                            <div>
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Amount</p>
                                <p class="text-mob-green font-bold">&#8358;{{ number_format($escrow->payout->amount, 2) }}</p>
                            </div>
                            <div>
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Gateway</p>
                                <p class="text-white capitalize">{{ $escrow->payout->payout_gateway?->value ?? '--' }}</p>
                            </div>
                            <div>
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Status</p>
                                @php
                                    $payoutStatusColors = [
                                        'pending' => 'text-mob-amber',
                                        'processing' => 'text-mob-cyan',
                                        'completed' => 'text-mob-green',
                                        'failed' => 'text-mob-red',
                                    ];
                                @endphp
                                <p class="{{ $payoutStatusColors[$escrow->payout->status] ?? 'text-mob-dim' }} capitalize font-medium">{{ $escrow->payout->status }}</p>
                            </div>
                            <div>
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Processed</p>
                                <p class="text-mob-muted">{{ $escrow->payout->processed_at?->format('M j, Y') ?? 'Pending' }}</p>
                            </div>
                        </div>
                        @if($escrow->payout->payout_reference)
                            <div class="mt-3 pt-3 border-t border-mob-border">
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Reference</p>
                                <p class="text-mob-muted text-xs font-mono">{{ $escrow->payout->payout_reference }}</p>
                            </div>
                        @endif
                    </div>
                </div>
            @endif

            <!-- Tickets Table -->
            <div class="bg-mob-card border border-mob-border rounded-xl overflow-hidden">
                <div class="px-5 py-4 border-b border-mob-border flex items-center justify-between">
                    <h3 class="text-sm font-semibold text-white">Tickets</h3>
                    <div class="flex items-center gap-3 text-xs">
                        <span class="text-mob-green">{{ $ticketBreakdown['paid'] }} paid</span>
                        @if($ticketBreakdown['checked_in'] > 0)
                            <span class="text-mob-cyan">{{ $ticketBreakdown['checked_in'] }} checked in</span>
                        @endif
                        @if($ticketBreakdown['refunded'] > 0)
                            <span class="text-mob-dim">{{ $ticketBreakdown['refunded'] }} refunded</span>
                        @endif
                        @if($ticketBreakdown['refund_processing'] > 0)
                            <span class="text-mob-amber">{{ $ticketBreakdown['refund_processing'] }} processing</span>
                        @endif
                    </div>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-sm text-left">
                        <thead>
                            <tr class="border-b border-mob-border">
                                <th class="px-5 py-3 text-xs font-medium text-mob-dim uppercase tracking-wider">Buyer</th>
                                <th class="px-5 py-3 text-xs font-medium text-mob-dim uppercase tracking-wider">Amount</th>
                                <th class="px-5 py-3 text-xs font-medium text-mob-dim uppercase tracking-wider">Qty</th>
                                <th class="px-5 py-3 text-xs font-medium text-mob-dim uppercase tracking-wider">Gateway</th>
                                <th class="px-5 py-3 text-xs font-medium text-mob-dim uppercase tracking-wider">Status</th>
                                <th class="px-5 py-3 text-xs font-medium text-mob-dim uppercase tracking-wider">Checked In</th>
                                <th class="px-5 py-3 text-xs font-medium text-mob-dim uppercase tracking-wider">Paid At</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-mob-border">
                            @forelse($escrow->tickets as $ticket)
                                @php
                                    $ticketStatusColors = [
                                        'pending' => 'text-mob-amber bg-mob-amber/10',
                                        'paid' => 'text-mob-green bg-mob-green/10',
                                        'refunded' => 'text-mob-dim bg-mob-elevated',
                                        'refund_processing' => 'text-mob-red bg-mob-red/10',
                                    ];
                                @endphp
                                <tr class="hover:bg-mob-elevated/50 transition-colors">
                                    <td class="px-5 py-3">
                                        <div class="flex items-center gap-2">
                                            <div class="w-6 h-6 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-[10px] font-bold shrink-0">
                                                {{ strtoupper(substr($ticket->user->name ?? '?', 0, 1)) }}
                                            </div>
                                            <span class="text-white text-sm truncate max-w-[120px]">{{ $ticket->user->name ?? 'Unknown' }}</span>
                                        </div>
                                    </td>
                                    <td class="px-5 py-3 text-white text-sm">&#8358;{{ number_format($ticket->amount, 2) }}</td>
                                    <td class="px-5 py-3 text-mob-muted text-sm">{{ $ticket->quantity }}</td>
                                    <td class="px-5 py-3 text-mob-muted text-xs capitalize">{{ $ticket->payment_gateway?->value ?? '--' }}</td>
                                    <td class="px-5 py-3">
                                        <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $ticketStatusColors[$ticket->status->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                            {{ str_replace('_', ' ', $ticket->status->value) }}
                                        </span>
                                    </td>
                                    <td class="px-5 py-3">
                                        @if($ticket->checked_in_at)
                                            <span class="text-mob-green text-xs font-medium">Yes</span>
                                        @else
                                            <span class="text-mob-dim text-xs">No</span>
                                        @endif
                                    </td>
                                    <td class="px-5 py-3 text-mob-dim text-xs">{{ $ticket->paid_at?->format('M j, Y g:i A') ?? '--' }}</td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="px-5 py-8 text-center text-mob-dim text-sm">No tickets found.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Audit Log -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Audit Log</h3>
                </div>
                <div class="divide-y divide-mob-border">
                    @forelse($escrow->escrowEventLogs as $log)
                        @php
                            $logColors = [
                                'created' => 'bg-mob-cyan',
                                'ticket_added' => 'bg-mob-green',
                                'ticket_refunded' => 'bg-mob-red',
                                'host_marked_complete' => 'bg-mob-purple',
                                'admin_approved' => 'bg-mob-green',
                                'admin_rejected' => 'bg-mob-red',
                                'funds_released' => 'bg-mob-green',
                                'refund_initiated' => 'bg-mob-red',
                                'refund_completed' => 'bg-mob-red',
                                'admin_override' => 'bg-mob-amber',
                                'event_started' => 'bg-mob-cyan',
                            ];
                        @endphp
                        <div class="px-5 py-3.5 flex items-start gap-3">
                            <div class="w-2 h-2 rounded-full {{ $logColors[$log->action->value] ?? 'bg-mob-dim' }} mt-1.5 shrink-0"></div>
                            <div class="flex-1 min-w-0">
                                <div class="flex items-center gap-2 flex-wrap">
                                    <span class="text-sm text-white font-medium">{{ ucwords(str_replace('_', ' ', $log->action->value)) }}</span>
                                    <span class="text-[10px] px-1.5 py-0.5 rounded bg-mob-elevated text-mob-dim uppercase">{{ $log->performed_by_role }}</span>
                                    @if($log->performer)
                                        <span class="text-mob-dim text-xs">by {{ $log->performer->name }}</span>
                                    @endif
                                </div>
                                <p class="text-xs text-mob-dim mt-0.5">{{ $log->created_at->format('M j, Y \a\t g:i A') }}</p>
                                @if($log->metadata)
                                    <div class="mt-1.5 text-xs text-mob-muted bg-mob-elevated rounded px-3 py-2">
                                        @foreach((array) $log->metadata as $key => $value)
                                            @if($value)
                                                <span class="inline-block mr-3">
                                                    <span class="text-mob-dim">{{ str_replace('_', ' ', $key) }}:</span>
                                                    <span class="text-white">{{ is_array($value) ? json_encode($value) : $value }}</span>
                                                </span>
                                            @endif
                                        @endforeach
                                    </div>
                                @endif
                            </div>
                        </div>
                    @empty
                        <div class="px-5 py-8 text-center text-mob-dim text-sm">No events logged yet.</div>
                    @endforelse
                </div>
            </div>
        </div>

        <!-- Right Column: Sidebar -->
        <div class="space-y-6">
            <!-- Host Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Host</h3>
                </div>
                <div class="p-5">
                    @if($escrow->host)
                        <a href="{{ route('admin.users.show', $escrow->host) }}" class="flex items-center gap-3 group">
                            <div class="w-10 h-10 rounded-full bg-mob-elevated flex items-center justify-center text-mob-purple text-sm font-bold shrink-0">
                                {{ strtoupper(substr($escrow->host->name, 0, 1)) }}
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm text-white group-hover:text-mob-cyan transition-colors font-medium truncate">{{ $escrow->host->name }}</p>
                                <p class="text-xs text-mob-dim truncate">{{ $escrow->host->email }}</p>
                            </div>
                        </a>
                        <div class="mt-3 pt-3 border-t border-mob-border space-y-2">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Role</span>
                                <span class="text-mob-purple capitalize font-medium">{{ $escrow->host->role->value }}</span>
                            </div>
                            @if($escrow->host->isSuspended())
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-mob-dim">Status</span>
                                    <span class="text-mob-red font-medium">Suspended</span>
                                </div>
                            @endif
                        </div>
                    @else
                        <p class="text-mob-dim text-sm">Host not found.</p>
                    @endif
                </div>
            </div>

            <!-- Event Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Event</h3>
                </div>
                <div class="p-5">
                    @if($escrow->happening)
                        <p class="text-white text-sm font-medium mb-2">{{ $escrow->happening->title }}</p>
                        <div class="space-y-2">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Status</span>
                                @php
                                    $displayStatus = $escrow->happening->getDisplayStatus();
                                    $hapStatusColors = [
                                        'live' => 'text-mob-green',
                                        'upcoming' => 'text-mob-cyan',
                                        'expired' => 'text-mob-dim',
                                        'hidden' => 'text-mob-red',
                                        'ended' => 'text-mob-dim',
                                    ];
                                @endphp
                                <span class="{{ $hapStatusColors[$displayStatus] ?? 'text-mob-dim' }} uppercase font-medium">{{ $displayStatus }}</span>
                            </div>
                            @if($escrow->happening->starts_at)
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-mob-dim">Started</span>
                                    <span class="text-mob-muted">{{ $escrow->happening->starts_at->format('M j, Y') }}</span>
                                </div>
                            @endif
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Ticket Price</span>
                                <span class="text-white font-medium">&#8358;{{ number_format($escrow->happening->ticket_price ?? 0, 2) }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Tickets Sold</span>
                                <span class="text-mob-muted">{{ $escrow->happening->tickets_sold ?? 0 }} / {{ $escrow->happening->ticket_quantity ?? '∞' }}</span>
                            </div>
                        </div>
                        <div class="mt-3 pt-3 border-t border-mob-border">
                            <a href="{{ route('admin.happenings.show', $escrow->happening) }}" class="text-mob-cyan text-xs font-medium hover:underline">
                                View Event Details &rarr;
                            </a>
                        </div>
                    @else
                        <p class="text-mob-dim text-sm">Event has been deleted.</p>
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
                        <span class="text-mob-dim">Escrow ID</span>
                        <span class="text-mob-muted">#{{ $escrow->id }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">UUID</span>
                        <span class="text-mob-muted font-mono text-[10px]">{{ Str::limit($escrow->uuid, 16) }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Created</span>
                        <span class="text-mob-muted">{{ $escrow->created_at->format('M j, Y') }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Last Updated</span>
                        <span class="text-mob-muted">{{ $escrow->updated_at->format('M j, Y') }}</span>
                    </div>
                    @if($escrow->host_completed_at)
                        <div class="flex items-center justify-between text-xs pt-2 border-t border-mob-border">
                            <span class="text-mob-dim">Host completed</span>
                            <span class="text-mob-purple font-medium">{{ $escrow->host_completed_at->diffForHumans() }}</span>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
