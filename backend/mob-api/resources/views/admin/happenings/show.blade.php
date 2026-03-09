@extends('admin.layouts.app')

@section('title', $happening->title)
@section('page-title', $happening->title)
@section('page-subtitle', 'Happening detail')

@section('content')
    <!-- Back Link -->
    <div class="mb-6">
        <a href="{{ route('admin.happenings.index') }}" class="text-mob-dim hover:text-mob-cyan text-sm transition-colors inline-flex items-center gap-1.5">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Happenings
        </a>
    </div>

    @php
        $displayStatus = $happening->getDisplayStatus();
        $statusColors = [
            'live'     => 'text-mob-green bg-mob-green/10 border-mob-green/20',
            'upcoming' => 'text-mob-cyan bg-mob-cyan/10 border-mob-cyan/20',
            'expired'  => 'text-mob-dim bg-mob-elevated border-mob-border',
            'hidden'   => 'text-mob-red bg-mob-red/10 border-mob-red/20',
            'ended'    => 'text-mob-dim bg-mob-elevated border-mob-border',
        ];
        $categoryColors = [
            'party_nightlife'   => 'text-mob-magenta bg-mob-magenta/10',
            'food_drinks'       => 'text-mob-amber bg-mob-amber/10',
            'hangouts_social'   => 'text-mob-green bg-mob-green/10',
            'music_performance' => 'text-mob-purple bg-mob-purple/10',
            'games_activities'  => 'text-blue-400 bg-blue-400/10',
            'art_culture'       => 'text-mob-cyan bg-mob-cyan/10',
            'study_work'        => 'text-indigo-400 bg-indigo-400/10',
            'popups_street'     => 'text-orange-400 bg-orange-400/10',
        ];
        $catValue = $happening->category->value;
    @endphp

    <!-- Hidden Banner -->
    @if($happening->isHidden())
        <div class="mb-6 bg-mob-red/10 border border-mob-red/20 rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-red shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L6.5 6.5m3.378 3.378l4.242 4.242M6.5 6.5L3 3m3.5 3.5l10 10M17.5 17.5L21 21"/></svg>
                <div class="flex-1">
                    <p class="text-mob-red font-semibold text-sm">This happening is hidden</p>
                    @if($happening->hidden_reason)
                        <p class="text-mob-red/80 text-xs mt-1">Reason: {{ $happening->hidden_reason }}</p>
                    @endif
                    @if($happening->hiddenByUser)
                        <p class="text-mob-red/60 text-xs mt-0.5">Hidden by {{ $happening->hiddenByUser->name }}</p>
                    @endif
                    <p class="text-mob-red/60 text-xs mt-0.5">DB status: {{ $happening->status->value }}</p>
                </div>
                <form method="POST" action="{{ route('admin.happenings.unhide', $happening) }}">
                    @csrf
                    <button type="submit" class="px-4 py-1.5 bg-mob-green/15 text-mob-green text-xs font-medium rounded-lg hover:bg-mob-green/25 transition-colors cursor-pointer">
                        Restore
                    </button>
                </form>
            </div>
        </div>
    @endif

    <!-- Status + Badges Bar -->
    <div class="flex flex-wrap items-center gap-2 mb-6">
        <span class="text-xs px-2.5 py-1 rounded-lg uppercase border font-medium {{ $statusColors[$displayStatus] ?? 'text-mob-dim bg-mob-elevated border-mob-border' }}">
            {{ $displayStatus }}
        </span>
        <span class="inline-block text-xs px-2.5 py-1 rounded-lg font-medium {{ $categoryColors[$catValue] ?? 'text-mob-dim bg-mob-elevated' }}">
            {{ str_replace('_', ' ', ucwords($catValue, '_')) }}
        </span>
        <span class="text-xs px-2.5 py-1 rounded-lg bg-mob-elevated text-mob-muted border border-mob-border capitalize">{{ $happening->type->value }}</span>
        @if($happening->is_ticketed)
            <span class="text-xs px-2.5 py-1 rounded-lg bg-mob-purple/10 text-mob-purple border border-mob-purple/20 font-medium">Ticketed</span>
        @else
            <span class="text-xs px-2.5 py-1 rounded-lg bg-mob-elevated text-mob-dim border border-mob-border">Free</span>
        @endif
        @if($happening->reports && $happening->reports->count() > 0)
            <span class="text-xs px-2.5 py-1 rounded-lg bg-mob-red/10 text-mob-red border border-mob-red/20 font-medium">
                {{ $happening->reports->count() }} {{ Str::plural('report', $happening->reports->count()) }}
            </span>
        @endif
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Left Column: Details -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Core Details -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Details</h3>
                </div>
                <div class="p-5 space-y-4">
                    <div>
                        <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Title</p>
                        <p class="text-white text-base font-medium">{{ $happening->title }}</p>
                    </div>

                    @if($happening->description)
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Description</p>
                            <p class="text-mob-muted text-sm leading-relaxed whitespace-pre-line">{{ $happening->description }}</p>
                        </div>
                    @endif

                    @if($happening->address)
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Address</p>
                            <p class="text-mob-muted text-sm">{{ $happening->address }}</p>
                        </div>
                    @endif

                    <div class="grid grid-cols-2 lg:grid-cols-3 gap-4 pt-3 border-t border-mob-border">
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Coordinates</p>
                            <p class="text-mob-muted text-xs font-mono">{{ $happening->latitude }}, {{ $happening->longitude }}</p>
                        </div>
                        @if($happening->radius_meters)
                            <div>
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Radius</p>
                                <p class="text-mob-muted text-sm">{{ number_format($happening->radius_meters) }}m</p>
                            </div>
                        @endif
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Vibe Score</p>
                            <p class="text-white font-semibold">🔥 {{ number_format($happening->vibe_score, 1) }}</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 lg:grid-cols-3 gap-4 pt-3 border-t border-mob-border">
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Starts At</p>
                            <p class="text-mob-muted text-sm">{{ $happening->starts_at ? $happening->starts_at->format('M j, Y g:i A') : '—' }}</p>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Ends At</p>
                            <p class="text-mob-muted text-sm">{{ $happening->ends_at ? $happening->ends_at->format('M j, Y g:i A') : '—' }}</p>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Expires At</p>
                            <p class="text-mob-muted text-sm">{{ $happening->expires_at ? $happening->expires_at->format('M j, Y g:i A') : '—' }}</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-4 pt-3 border-t border-mob-border">
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Activity Level</p>
                            @php
                                $actLevel = $happening->activity_level->value ?? 'low';
                                $activityColors = ['high' => 'text-mob-green', 'medium' => 'text-mob-amber', 'low' => 'text-mob-dim'];
                            @endphp
                            <p class="{{ $activityColors[$actLevel] ?? 'text-mob-dim' }} capitalize font-medium text-sm">{{ $actLevel }}</p>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">DB Status</p>
                            <p class="text-mob-muted text-sm capitalize">{{ $happening->status->value }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticketing -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border flex items-center justify-between">
                    <h3 class="text-sm font-semibold text-white">Ticketing</h3>
                    @if($happening->is_ticketed)
                        <span class="text-[10px] px-2 py-0.5 rounded bg-mob-purple/10 text-mob-purple font-medium uppercase">Ticketed</span>
                    @endif
                </div>
                <div class="p-5">
                    @if($happening->is_ticketed)
                        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-5">
                            <div class="bg-mob-elevated rounded-lg px-4 py-3">
                                <p class="text-mob-dim text-[10px] uppercase tracking-wider">Price</p>
                                <p class="text-white font-bold text-lg">&#8358;{{ number_format($happening->ticket_price ?? 0, 2) }}</p>
                            </div>
                            <div class="bg-mob-elevated rounded-lg px-4 py-3">
                                <p class="text-mob-dim text-[10px] uppercase tracking-wider">Sold</p>
                                <p class="text-mob-green font-bold text-lg">{{ $ticketStats['total_sold'] ?? $happening->tickets_sold ?? 0 }}</p>
                            </div>
                            <div class="bg-mob-elevated rounded-lg px-4 py-3">
                                <p class="text-mob-dim text-[10px] uppercase tracking-wider">Available</p>
                                <p class="text-white font-bold text-lg">{{ $happening->ticket_quantity ? $happening->ticket_quantity - ($happening->tickets_sold ?? 0) : '∞' }}</p>
                            </div>
                            <div class="bg-mob-elevated rounded-lg px-4 py-3">
                                <p class="text-mob-dim text-[10px] uppercase tracking-wider">Revenue</p>
                                <p class="text-mob-cyan font-bold text-lg">&#8358;{{ number_format($ticketStats['total_revenue'] ?? 0, 2) }}</p>
                            </div>
                        </div>

                        <!-- Escrow Status -->
                        @if($happening->escrow)
                            @php
                                $escrow = $happening->escrow;
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
                            <div class="p-4 bg-mob-elevated rounded-lg border border-mob-border mb-5">
                                <div class="flex items-center justify-between mb-3">
                                    <p class="text-mob-dim text-xs uppercase tracking-wider">Escrow</p>
                                    <span class="inline-block px-2 py-0.5 rounded text-xs font-medium uppercase {{ $escrowStatusColors[$escrow->status->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                        {{ str_replace('_', ' ', $escrow->status->value) }}
                                    </span>
                                </div>
                                <div class="grid grid-cols-3 gap-3 text-sm">
                                    <div>
                                        <p class="text-mob-dim text-xs">Total</p>
                                        <p class="text-white font-semibold">&#8358;{{ number_format($escrow->total_amount, 2) }}</p>
                                    </div>
                                    <div>
                                        <p class="text-mob-dim text-xs">Platform Fee</p>
                                        <p class="text-mob-amber font-semibold">&#8358;{{ number_format($escrow->platform_fee, 2) }}</p>
                                    </div>
                                    <div>
                                        <p class="text-mob-dim text-xs">Host Payout</p>
                                        <p class="text-mob-green font-semibold">&#8358;{{ number_format($escrow->host_payout_amount, 2) }}</p>
                                    </div>
                                </div>
                                <div class="mt-3 pt-3 border-t border-mob-border">
                                    <a href="{{ route('admin.escrow.show', $escrow) }}" class="text-mob-purple text-xs font-medium hover:underline">
                                        View Full Escrow Record &rarr;
                                    </a>
                                </div>
                            </div>
                        @endif

                        <!-- Recent Tickets -->
                        @if($happening->tickets->count() > 0)
                            <div>
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-3">Recent Tickets</p>
                                <div class="space-y-2">
                                    @foreach($happening->tickets->take(10) as $ticket)
                                        @php
                                            $ticketStatusColors = [
                                                'paid' => 'text-mob-green bg-mob-green/10',
                                                'pending' => 'text-mob-amber bg-mob-amber/10',
                                                'refunded' => 'text-mob-dim bg-mob-elevated',
                                                'refund_processing' => 'text-mob-amber bg-mob-amber/10',
                                            ];
                                        @endphp
                                        <div class="flex items-center justify-between gap-3 py-2 px-3 bg-mob-card rounded-lg border border-mob-border">
                                            <div class="flex items-center gap-2 min-w-0">
                                                <div class="w-6 h-6 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-[10px] font-bold shrink-0">
                                                    {{ strtoupper(substr($ticket->user->name ?? '?', 0, 1)) }}
                                                </div>
                                                <span class="text-white text-xs truncate">{{ $ticket->user->name ?? 'Unknown' }}</span>
                                            </div>
                                            <div class="flex items-center gap-3 shrink-0">
                                                <span class="text-mob-muted text-xs">&#8358;{{ number_format($ticket->amount, 2) }}</span>
                                                <span class="text-xs">x{{ $ticket->quantity }}</span>
                                                <span class="inline-block px-1.5 py-0.5 rounded text-[10px] font-medium uppercase {{ $ticketStatusColors[$ticket->status->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                                    {{ str_replace('_', ' ', $ticket->status->value) }}
                                                </span>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            </div>
                        @endif
                    @else
                        <p class="text-mob-dim text-sm">This happening is not ticketed.</p>
                    @endif
                </div>
            </div>

            <!-- Snaps Grid -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border flex items-center justify-between">
                    <h3 class="text-sm font-semibold text-white">Snaps</h3>
                    @if($happening->snaps && $happening->snaps->count() > 0)
                        <span class="text-xs px-2 py-0.5 rounded bg-mob-elevated text-mob-dim">{{ $happening->snaps->count() }}</span>
                    @endif
                </div>
                <div class="p-5">
                    @if($happening->snaps && $happening->snaps->count() > 0)
                        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
                            @foreach($happening->snaps as $snap)
                                <div class="relative aspect-square rounded-lg overflow-hidden bg-mob-elevated border border-mob-border">
                                    @if($snap->thumbnail_url || $snap->media_url)
                                        <img src="{{ $snap->thumbnail_url ?? $snap->media_url }}" alt="Snap" class="w-full h-full object-cover" loading="lazy" />
                                    @else
                                        <div class="w-full h-full flex items-center justify-center text-mob-dim">
                                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                                        </div>
                                    @endif
                                    @if($snap->is_cover)
                                        <span class="absolute top-1.5 left-1.5 text-[10px] px-1.5 py-0.5 rounded bg-mob-cyan/90 text-black font-medium">Cover</span>
                                    @endif
                                    <span class="absolute bottom-1.5 right-1.5 text-[10px] px-1.5 py-0.5 rounded bg-black/60 text-mob-muted uppercase">{{ $snap->media_type ?? 'image' }}</span>
                                </div>
                            @endforeach
                        </div>
                    @else
                        <p class="text-mob-dim text-sm">No snaps uploaded.</p>
                    @endif
                </div>
            </div>

            <!-- Reports -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border flex items-center justify-between">
                    <h3 class="text-sm font-semibold text-white">Reports</h3>
                    @if($happening->reports && $happening->reports->count() > 0)
                        <span class="text-xs px-2 py-0.5 rounded bg-mob-red/10 text-mob-red font-medium">{{ $happening->reports->count() }}</span>
                    @endif
                </div>
                <div class="divide-y divide-mob-border">
                    @forelse($happening->reports ?? [] as $report)
                        <div class="px-5 py-3.5">
                            <div class="flex items-start justify-between gap-3">
                                <div class="flex-1 min-w-0">
                                    <div class="flex items-center gap-2 mb-1">
                                        <p class="text-sm text-white font-medium">{{ $report->user->name ?? 'Unknown' }}</p>
                                        @php $reasonValue = $report->reason->value ?? $report->reason; @endphp
                                        <span class="text-[10px] px-1.5 py-0.5 rounded text-mob-amber bg-mob-amber/10 uppercase font-medium">{{ str_replace('_', ' ', $reasonValue) }}</span>
                                    </div>
                                    @if($report->details)
                                        <p class="text-mob-muted text-xs mt-0.5">{{ $report->details }}</p>
                                    @endif
                                </div>
                                <span class="text-mob-dim text-xs shrink-0">{{ $report->created_at->format('M j, Y') }}</span>
                            </div>
                        </div>
                    @empty
                        <p class="px-5 py-8 text-sm text-mob-dim text-center">No reports filed.</p>
                    @endforelse
                </div>
            </div>
        </div>

        <!-- Right Column: Sidebar -->
        <div class="space-y-6">
            <!-- Creator -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Creator</h3>
                </div>
                <div class="p-5">
                    @if($happening->user)
                        <a href="{{ route('admin.users.show', $happening->user) }}" class="flex items-center gap-3 group">
                            <div class="w-10 h-10 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-sm font-bold shrink-0">
                                {{ strtoupper(substr($happening->user->name, 0, 1)) }}
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm text-white group-hover:text-mob-cyan transition-colors truncate font-medium">{{ $happening->user->name }}</p>
                                <p class="text-xs text-mob-dim truncate">{{ $happening->user->email }}</p>
                            </div>
                        </a>
                        <div class="mt-3 pt-3 border-t border-mob-border space-y-2">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-mob-dim">Role</span>
                                @php
                                    $roleColors = [
                                        'admin' => 'text-mob-cyan',
                                        'host' => 'text-mob-purple',
                                        'moderator' => 'text-mob-amber',
                                        'user' => 'text-mob-muted',
                                        'guest' => 'text-mob-dim',
                                    ];
                                @endphp
                                <span class="{{ $roleColors[$happening->user->role->value] ?? 'text-mob-muted' }} capitalize font-medium">{{ $happening->user->role->value }}</span>
                            </div>
                            @if($happening->user->isSuspended())
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-mob-dim">Status</span>
                                    <span class="text-mob-red font-medium">Suspended</span>
                                </div>
                            @endif
                        </div>
                    @else
                        <p class="text-mob-dim text-sm">Creator not found.</p>
                    @endif
                </div>
            </div>

            <!-- Moderation Actions -->
            @if(!$happening->isHidden())
                <div class="bg-mob-card border border-mob-border rounded-xl">
                    <div class="px-5 py-4 border-b border-mob-border">
                        <h3 class="text-sm font-semibold text-mob-red">Hide Happening</h3>
                    </div>
                    <form method="POST" action="{{ route('admin.happenings.hide', $happening) }}" class="p-5">
                        @csrf
                        <div class="mb-3">
                            <label for="hide_reason" class="block text-mob-dim text-xs uppercase tracking-wider mb-2">
                                Reason <span class="text-mob-red">*</span>
                            </label>
                            <textarea
                                id="hide_reason"
                                name="reason"
                                rows="2"
                                required
                                placeholder="Why is this happening being hidden?"
                                class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-red focus:outline-none resize-none"
                            ></textarea>
                            @error('reason')
                                <p class="text-mob-red text-xs mt-1">{{ $message }}</p>
                            @enderror
                        </div>
                        <p class="text-mob-dim text-xs mb-3">This removes the happening from all feeds. If ticketed, escrow may need separate action.</p>
                        <button type="submit"
                                class="w-full px-4 py-2.5 text-sm font-medium rounded-lg bg-mob-red/15 text-mob-red hover:bg-mob-red/25 transition-colors cursor-pointer"
                                onclick="return confirm('Hide this happening? It will be removed from all feeds.')">
                            Hide Happening
                        </button>
                    </form>
                </div>
            @endif

            <!-- Metadata -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Metadata</h3>
                </div>
                <div class="p-5 space-y-3">
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">UUID</span>
                        <span class="text-mob-muted font-mono">{{ Str::limit($happening->uuid, 18) }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">ID</span>
                        <span class="text-mob-muted">#{{ $happening->id }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Created</span>
                        <span class="text-mob-muted">{{ $happening->created_at->format('M j, Y g:i A') }}</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="text-mob-dim">Updated</span>
                        <span class="text-mob-muted">{{ $happening->updated_at->format('M j, Y g:i A') }}</span>
                    </div>
                    @if($happening->escrow)
                        <div class="pt-2 border-t border-mob-border">
                            <a href="{{ route('admin.escrow.show', $happening->escrow) }}" class="text-mob-purple text-xs font-medium hover:underline">
                                View Escrow Record &rarr;
                            </a>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
