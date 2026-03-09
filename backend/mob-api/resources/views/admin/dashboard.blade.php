@extends('admin.layouts.app')

@section('title', 'Dashboard')
@section('page-title', 'Dashboard')
@section('page-subtitle', 'Overview of your platform')

@section('content')
    <!-- Action Items -->
    @if($pendingVerifications > 0 || $pendingEscrow > 0 || $pendingReports > 0)
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        @if($pendingVerifications > 0)
        <a href="{{ route('admin.verifications.index') }}" class="bg-mob-amber/10 border border-mob-amber/20 rounded-xl p-4 flex items-center gap-3 hover:bg-mob-amber/15 transition-colors">
            <div class="w-10 h-10 rounded-full bg-mob-amber/20 flex items-center justify-center shrink-0">
                <svg class="w-5 h-5 text-mob-amber" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <p class="text-mob-amber font-semibold text-sm">{{ $pendingVerifications }} pending verification{{ $pendingVerifications > 1 ? 's' : '' }}</p>
                <p class="text-mob-dim text-xs">Review host applications</p>
            </div>
        </a>
        @endif
        @if($pendingEscrow > 0 && auth()->user()->role === \App\Enums\UserRole::ADMIN)
        <a href="{{ route('admin.escrow.index') }}" class="bg-mob-cyan/10 border border-mob-cyan/20 rounded-xl p-4 flex items-center gap-3 hover:bg-mob-cyan/15 transition-colors">
            <div class="w-10 h-10 rounded-full bg-mob-cyan/20 flex items-center justify-center shrink-0">
                <svg class="w-5 h-5 text-mob-cyan" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <p class="text-mob-cyan font-semibold text-sm">{{ $pendingEscrow }} payout{{ $pendingEscrow > 1 ? 's' : '' }} pending</p>
                <p class="text-mob-dim text-xs">Review and release escrow</p>
            </div>
        </a>
        @endif
        @if($pendingReports > 0)
        <a href="{{ route('admin.reports.index') }}" class="bg-mob-red/10 border border-mob-red/20 rounded-xl p-4 flex items-center gap-3 hover:bg-mob-red/15 transition-colors">
            <div class="w-10 h-10 rounded-full bg-mob-red/20 flex items-center justify-center shrink-0">
                <svg class="w-5 h-5 text-mob-red" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 21v-4m0 0V5a2 2 0 012-2h6.5l1 1H21l-3 6 3 6h-8.5l-1-1H5a2 2 0 00-2 2zm9-13.5V9"/></svg>
            </div>
            <div>
                <p class="text-mob-red font-semibold text-sm">{{ $pendingReports }} report{{ $pendingReports > 1 ? 's' : '' }} pending</p>
                <p class="text-mob-dim text-xs">Review flagged content</p>
            </div>
        </a>
        @endif
    </div>
    @endif

    <!-- Primary KPI Cards -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div class="bg-mob-card rounded-xl border border-mob-border p-5">
            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Total Users</p>
            <p class="text-2xl font-bold text-white">{{ number_format($totalUsers) }}</p>
            <p class="text-mob-green text-xs mt-1">+{{ $newUsersThisWeek }} this week</p>
        </div>
        <div class="bg-mob-card rounded-xl border border-mob-border p-5">
            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Active Happenings</p>
            <p class="text-2xl font-bold text-white">{{ number_format($activeHappenings) }}</p>
            <p class="text-mob-dim text-xs mt-1">{{ number_format($totalHappenings) }} total</p>
        </div>
        <div class="bg-mob-card rounded-xl border border-mob-border p-5">
            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Tickets Sold</p>
            <p class="text-2xl font-bold text-white">{{ number_format($totalTicketsSold) }}</p>
            <p class="text-mob-dim text-xs mt-1">All time</p>
        </div>
        <div class="bg-mob-card rounded-xl border border-mob-border p-5">
            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Total Revenue</p>
            <p class="text-2xl font-bold text-mob-cyan">&#8358;{{ number_format($totalRevenue) }}</p>
            <p class="text-mob-green text-xs mt-1">&#8358;{{ number_format($revenueToday) }} today</p>
        </div>
    </div>

    <!-- Secondary KPIs -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div class="bg-mob-card rounded-xl border border-mob-border p-5">
            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Verified Hosts</p>
            <p class="text-xl font-bold text-mob-green">{{ $verifiedHosts }}</p>
        </div>
        <div class="bg-mob-card rounded-xl border border-mob-border p-5">
            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">New Users Today</p>
            <p class="text-xl font-bold text-white">{{ $newUsersToday }}</p>
        </div>
        <div class="bg-mob-card rounded-xl border border-mob-border p-5">
            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Pending Payouts</p>
            <p class="text-xl font-bold text-mob-amber">{{ $pendingEscrow }}</p>
        </div>
        <div class="bg-mob-card rounded-xl border border-mob-border p-5">
            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Open Reports</p>
            <p class="text-xl font-bold text-mob-red">{{ $pendingReports }}</p>
        </div>
    </div>

    <!-- Revenue Chart + Recent Activity -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        <!-- Revenue Chart -->
        <div class="lg:col-span-2 bg-mob-card rounded-xl border border-mob-border p-6">
            <h3 class="text-white font-semibold mb-4">Revenue — Last 7 Days</h3>
            <div class="flex items-end gap-3 h-48">
                @php $maxRevenue = max($revenueChart->pluck('amount')->max(), 1); @endphp
                @foreach($revenueChart as $day)
                    <div class="flex-1 flex flex-col items-center gap-2">
                        <span class="text-mob-dim text-[10px]">&#8358;{{ number_format($day['amount']) }}</span>
                        <div class="w-full rounded-t-md transition-all"
                             style="height: {{ ($day['amount'] / $maxRevenue) * 100 }}%; min-height: 4px; background: linear-gradient(to top, #00F0FF, #A855F7);"></div>
                        <span class="text-mob-dim text-[10px]">{{ $day['date'] }}</span>
                    </div>
                @endforeach
            </div>
        </div>

        <!-- Recent Activity -->
        <div class="bg-mob-card rounded-xl border border-mob-border p-6">
            <h3 class="text-white font-semibold mb-4">Recent Activity</h3>
            <div class="space-y-4">
                @foreach($recentTickets as $ticket)
                    <div class="flex items-start gap-3">
                        <div class="w-8 h-8 rounded-full bg-mob-green/15 flex items-center justify-center shrink-0 mt-0.5">
                            <svg class="w-4 h-4 text-mob-green" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/></svg>
                        </div>
                        <div class="min-w-0">
                            <p class="text-white text-sm">{{ $ticket->user->name ?? 'Unknown' }} <span class="text-mob-dim">bought ticket</span></p>
                            <p class="text-mob-dim text-xs truncate">{{ $ticket->happening->title ?? '' }} — &#8358;{{ number_format($ticket->amount) }}</p>
                            <p class="text-mob-dim text-xs">{{ $ticket->paid_at?->diffForHumans() }}</p>
                        </div>
                    </div>
                @endforeach

                @foreach($recentUsers->take(3) as $user)
                    <div class="flex items-start gap-3">
                        <div class="w-8 h-8 rounded-full bg-mob-cyan/15 flex items-center justify-center shrink-0 mt-0.5">
                            <svg class="w-4 h-4 text-mob-cyan" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                        </div>
                        <div>
                            <p class="text-white text-sm">{{ $user->name }} <span class="text-mob-dim">joined</span></p>
                            <p class="text-mob-dim text-xs">{{ $user->created_at->diffForHumans() }}</p>
                        </div>
                    </div>
                @endforeach

                @if($recentTickets->isEmpty() && $recentUsers->isEmpty())
                    <p class="text-mob-dim text-sm text-center py-4">No recent activity.</p>
                @endif
            </div>
        </div>
    </div>

    <!-- Bottom Section: Recent Happenings + Pending Reports -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Recent Happenings -->
        <div class="bg-mob-card border border-mob-border rounded-xl">
            <div class="px-5 py-4 border-b border-mob-border flex items-center justify-between">
                <h3 class="text-sm font-semibold text-white">Recent Happenings</h3>
                <a href="{{ route('admin.happenings.index') }}" class="text-xs text-mob-cyan hover:underline">View all</a>
            </div>
            <div class="divide-y divide-mob-border">
                @forelse($recentHappenings as $happening)
                    <a href="{{ route('admin.happenings.show', $happening) }}" class="flex items-center gap-3 px-5 py-3 hover:bg-mob-elevated/50 transition-colors">
                        <div class="flex-1 min-w-0">
                            <p class="text-sm text-white truncate">{{ $happening->title }}</p>
                            <p class="text-xs text-mob-dim">by {{ $happening->user->name ?? 'Unknown' }} &middot; {{ $happening->created_at->diffForHumans() }}</p>
                        </div>
                        @php
                            $displayStatus = $happening->getDisplayStatus();
                            $statusColors = ['live' => 'text-mob-green bg-mob-green/10', 'upcoming' => 'text-mob-cyan bg-mob-cyan/10', 'expired' => 'text-mob-dim bg-mob-elevated', 'hidden' => 'text-mob-red bg-mob-red/10', 'ended' => 'text-mob-dim bg-mob-elevated'];
                        @endphp
                        <span class="text-xs px-2 py-0.5 rounded uppercase {{ $statusColors[$displayStatus] ?? 'text-mob-dim bg-mob-elevated' }}">{{ $displayStatus }}</span>
                    </a>
                @empty
                    <p class="px-5 py-4 text-sm text-mob-dim">No happenings yet.</p>
                @endforelse
            </div>
        </div>

        <!-- Pending Reports -->
        <div class="bg-mob-card border border-mob-border rounded-xl">
            <div class="px-5 py-4 border-b border-mob-border flex items-center justify-between">
                <h3 class="text-sm font-semibold text-white">Pending Reports</h3>
                @if($pendingReportsList->count() > 0)
                    <a href="{{ route('admin.reports.index') }}" class="text-xs text-mob-cyan hover:underline">View all</a>
                @endif
            </div>
            <div class="divide-y divide-mob-border">
                @forelse($pendingReportsList as $report)
                    <a href="{{ route('admin.reports.show', $report) }}" class="flex items-center gap-3 px-5 py-3 hover:bg-mob-elevated/50 transition-colors">
                        <span class="w-2 h-2 rounded-full bg-mob-red shrink-0"></span>
                        <div class="flex-1 min-w-0">
                            <p class="text-sm text-white truncate">{{ $report->happening->title ?? 'Deleted Happening' }}</p>
                            <p class="text-xs text-mob-dim">{{ ucfirst(str_replace('_', ' ', $report->reason->value)) }} &middot; by {{ $report->user->name ?? 'Unknown' }} &middot; {{ $report->created_at->diffForHumans() }}</p>
                        </div>
                    </a>
                @empty
                    <p class="px-5 py-4 text-sm text-mob-dim">No pending reports.</p>
                @endforelse
            </div>
        </div>
    </div>
@endsection
