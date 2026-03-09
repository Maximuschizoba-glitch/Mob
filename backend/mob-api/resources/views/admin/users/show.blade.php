@extends('admin.layouts.app')

@section('title', $user->name)
@section('page-title', $user->name)
@section('page-subtitle', 'User detail')

@section('content')
    <!-- Back Link -->
    <div class="mb-6">
        <a href="{{ route('admin.users.index') }}" class="text-mob-dim hover:text-mob-cyan text-sm transition-colors inline-flex items-center gap-1.5">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Users
        </a>
    </div>

    <!-- Suspension Banner -->
    @if($user->isSuspended())
        <div class="mb-6 bg-mob-red/10 border border-mob-red/20 rounded-xl p-4">
            <div class="flex items-start gap-3">
                <svg class="w-5 h-5 text-mob-red shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"/></svg>
                <div class="flex-1">
                    <p class="text-mob-red font-semibold text-sm">This user is suspended</p>
                    @if($user->suspension_reason)
                        <p class="text-mob-red/80 text-xs mt-1">Reason: {{ $user->suspension_reason }}</p>
                    @endif
                    <p class="text-mob-red/60 text-xs mt-0.5">Since {{ $user->suspended_at->format('M j, Y \a\t g:i A') }}</p>
                </div>
                <form method="POST" action="{{ route('admin.users.unsuspend', $user) }}">
                    @csrf
                    <button type="submit" class="px-4 py-1.5 bg-mob-green/15 text-mob-green text-xs font-medium rounded-lg hover:bg-mob-green/25 transition-colors cursor-pointer">
                        Unsuspend
                    </button>
                </form>
            </div>
        </div>
    @endif

    <!-- User Detail Card -->
    <div class="bg-mob-card border border-mob-border rounded-xl p-6 mb-6">
        <div class="flex flex-col sm:flex-row sm:items-start gap-6">
            <!-- Avatar -->
            <div class="w-16 h-16 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-xl font-bold shrink-0">
                {{ strtoupper(substr($user->name, 0, 1)) }}
            </div>

            <!-- Info -->
            <div class="flex-1 min-w-0">
                <div class="flex flex-col sm:flex-row sm:items-center gap-2 mb-4">
                    <h2 class="text-xl font-semibold text-white">{{ $user->name }}</h2>
                    @php
                        $roleColors = [
                            'admin' => 'text-mob-cyan bg-mob-cyan/10',
                            'host' => 'text-mob-purple bg-mob-purple/10',
                            'moderator' => 'text-mob-amber bg-mob-amber/10',
                            'user' => 'text-mob-dim bg-mob-elevated',
                            'guest' => 'text-mob-dim bg-mob-elevated',
                        ];
                        $roleClass = $roleColors[$user->role->value] ?? 'text-mob-dim bg-mob-elevated';
                    @endphp
                    <span class="inline-block px-2.5 py-0.5 rounded text-xs font-medium uppercase {{ $roleClass }} w-fit">
                        {{ $user->role->value }}
                    </span>
                    @if($user->isSuspended())
                        <span class="inline-block px-2.5 py-0.5 rounded text-xs font-medium bg-mob-red/15 text-mob-red w-fit">Suspended</span>
                    @endif
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 text-sm">
                    <div>
                        <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Email</p>
                        <p class="text-white">{{ $user->email ?? '--' }}</p>
                    </div>
                    <div>
                        <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Phone</p>
                        <p class="text-white">{{ $user->phone ?? '--' }}</p>
                    </div>
                    <div>
                        <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Joined</p>
                        <p class="text-white">{{ $user->created_at->format('M j, Y \a\t g:i A') }}</p>
                    </div>
                    <div>
                        <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Email Verified</p>
                        @if($user->email_verified_at)
                            <span class="text-mob-green text-xs font-medium">Verified {{ $user->email_verified_at->format('M j, Y') }}</span>
                        @else
                            <span class="text-mob-dim text-xs">Not verified</span>
                        @endif
                    </div>
                    <div>
                        <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Phone Verified</p>
                        @if($user->phone_verified_at)
                            <span class="text-mob-green text-xs font-medium">Verified {{ $user->phone_verified_at->format('M j, Y') }}</span>
                        @else
                            <span class="text-mob-dim text-xs">Not verified</span>
                        @endif
                    </div>
                    <div>
                        <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">UUID</p>
                        <p class="text-mob-dim text-xs font-mono">{{ $user->uuid }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Actions Section -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        <!-- Suspend / Unsuspend -->
        @if(!$user->isSuspended() && $user->role !== \App\Enums\UserRole::ADMIN)
            <div class="bg-mob-card border border-mob-border rounded-xl p-5">
                <h3 class="text-white text-sm font-semibold mb-3">Suspend User</h3>
                <form method="POST" action="{{ route('admin.users.suspend', $user) }}">
                    @csrf
                    <textarea name="reason" rows="2" required placeholder="Reason for suspension..."
                              class="w-full bg-mob-elevated border border-mob-border rounded-lg px-3 py-2 text-sm text-white placeholder-mob-dim focus:border-mob-amber focus:outline-none resize-none mb-3"></textarea>
                    @error('reason')
                        <p class="text-mob-red text-xs mb-2">{{ $message }}</p>
                    @enderror
                    <button type="submit" class="w-full px-4 py-2 bg-mob-amber/10 text-mob-amber text-sm font-medium rounded-lg hover:bg-mob-amber/20 transition-colors cursor-pointer" onclick="return confirm('Are you sure you want to suspend this user? Their API tokens will be revoked.')">
                        Suspend User
                    </button>
                </form>
            </div>
        @endif

        <!-- Delete (admin only) -->
        @if(auth()->user()->role === \App\Enums\UserRole::ADMIN && $user->role !== \App\Enums\UserRole::ADMIN)
            <div class="bg-mob-card border border-mob-border rounded-xl p-5">
                <h3 class="text-white text-sm font-semibold mb-3">Danger Zone</h3>
                <p class="text-mob-dim text-xs mb-3">Permanently delete this user and all associated data. This cannot be undone.</p>
                <form method="POST" action="{{ route('admin.users.destroy', $user) }}" onsubmit="return confirm('Are you sure? This permanently deletes the user and cannot be undone.')">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="w-full px-4 py-2 bg-mob-red/10 text-mob-red text-sm font-medium rounded-lg hover:bg-mob-red/20 transition-colors cursor-pointer">
                        Delete User
                    </button>
                </form>
            </div>
        @endif
    </div>

    <!-- Tabbed Sections -->
    <div x-data="{ tab: 'happenings' }">
        <!-- Tab Navigation -->
        <div class="flex gap-1 border-b border-mob-border mb-6">
            <button
                @click="tab = 'happenings'"
                :class="tab === 'happenings' ? 'text-mob-cyan border-mob-cyan' : 'text-mob-dim border-transparent hover:text-white'"
                class="px-4 py-2.5 text-sm font-medium border-b-2 transition-colors -mb-px cursor-pointer"
            >
                Happenings
                @if($user->happenings->count() > 0)
                    <span class="ml-1.5 text-xs px-1.5 py-0.5 rounded bg-mob-elevated">{{ $user->happenings->count() }}</span>
                @endif
            </button>
            <button
                @click="tab = 'tickets'"
                :class="tab === 'tickets' ? 'text-mob-cyan border-mob-cyan' : 'text-mob-dim border-transparent hover:text-white'"
                class="px-4 py-2.5 text-sm font-medium border-b-2 transition-colors -mb-px cursor-pointer"
            >
                Tickets
                @if($user->tickets->count() > 0)
                    <span class="ml-1.5 text-xs px-1.5 py-0.5 rounded bg-mob-elevated">{{ $user->tickets->count() }}</span>
                @endif
            </button>
            @if($user->hostProfile)
                <button
                    @click="tab = 'host'"
                    :class="tab === 'host' ? 'text-mob-cyan border-mob-cyan' : 'text-mob-dim border-transparent hover:text-white'"
                    class="px-4 py-2.5 text-sm font-medium border-b-2 transition-colors -mb-px cursor-pointer"
                >
                    Host Profile
                </button>
            @endif
        </div>

        <!-- Happenings Tab -->
        <div x-show="tab === 'happenings'" x-cloak>
            @forelse($user->happenings as $happening)
                <div class="bg-mob-card border border-mob-border rounded-xl p-4 mb-3">
                    <div class="flex items-center justify-between gap-4">
                        <div class="flex-1 min-w-0">
                            <a href="{{ route('admin.happenings.show', $happening) }}" class="text-sm font-medium text-white hover:text-mob-cyan transition-colors truncate block">
                                {{ $happening->title }}
                            </a>
                            <div class="flex items-center gap-3 mt-1.5 text-xs text-mob-dim">
                                <span class="capitalize">{{ str_replace('_', ' ', $happening->category->value) }}</span>
                                <span>&middot;</span>
                                <span>{{ $happening->created_at->format('M j, Y') }}</span>
                                @if($happening->is_ticketed)
                                    <span>&middot;</span>
                                    <span class="text-mob-purple">Ticketed</span>
                                @endif
                            </div>
                        </div>
                        @php
                            $displayStatus = $happening->getDisplayStatus();
                            $statusColors = [
                                'live' => 'text-mob-green bg-mob-green/10',
                                'upcoming' => 'text-mob-cyan bg-mob-cyan/10',
                                'expired' => 'text-mob-dim bg-mob-elevated',
                                'hidden' => 'text-mob-red bg-mob-red/10',
                                'ended' => 'text-mob-dim bg-mob-elevated',
                            ];
                        @endphp
                        <span class="text-xs px-2.5 py-0.5 rounded uppercase font-medium shrink-0 {{ $statusColors[$displayStatus] ?? 'text-mob-dim bg-mob-elevated' }}">
                            {{ $displayStatus }}
                        </span>
                    </div>
                </div>
            @empty
                <div class="bg-mob-card border border-mob-border rounded-xl px-5 py-12 text-center">
                    <p class="text-mob-dim text-sm">This user has no happenings.</p>
                </div>
            @endforelse
        </div>

        <!-- Tickets Tab -->
        <div x-show="tab === 'tickets'" x-cloak>
            @forelse($user->tickets as $ticket)
                <div class="bg-mob-card border border-mob-border rounded-xl p-4 mb-3">
                    <div class="flex items-center justify-between gap-4">
                        <div class="flex-1 min-w-0">
                            <a href="{{ route('admin.tickets.show', $ticket) }}" class="text-sm font-medium text-white hover:text-mob-cyan transition-colors truncate block">
                                {{ $ticket->happening->title ?? 'Deleted Happening' }}
                            </a>
                            <div class="flex flex-wrap items-center gap-x-3 gap-y-1 mt-1.5 text-xs text-mob-dim">
                                <span>&#8358;{{ number_format($ticket->amount, 2) }}</span>
                                <span>&middot;</span>
                                <span>Qty: {{ $ticket->quantity }}</span>
                                <span>&middot;</span>
                                <span>{{ $ticket->paid_at ? $ticket->paid_at->format('M j, Y') : $ticket->created_at->format('M j, Y') }}</span>
                                <span>&middot;</span>
                                <span class="capitalize">{{ $ticket->payment_gateway?->value ?? '--' }}</span>
                            </div>
                        </div>
                        @php
                            $ticketStatusColors = [
                                'paid' => 'text-mob-green bg-mob-green/10',
                                'pending' => 'text-mob-amber bg-mob-amber/10',
                                'refunded' => 'text-mob-dim bg-mob-elevated',
                                'refund_processing' => 'text-mob-amber bg-mob-amber/10',
                            ];
                            $ticketStatusClass = $ticketStatusColors[$ticket->status->value] ?? 'text-mob-dim bg-mob-elevated';
                        @endphp
                        <span class="text-xs px-2.5 py-0.5 rounded uppercase font-medium shrink-0 {{ $ticketStatusClass }}">
                            {{ str_replace('_', ' ', $ticket->status->value) }}
                        </span>
                    </div>
                </div>
            @empty
                <div class="bg-mob-card border border-mob-border rounded-xl px-5 py-12 text-center">
                    <p class="text-mob-dim text-sm">This user has no tickets.</p>
                </div>
            @endforelse
        </div>

        <!-- Host Profile Tab -->
        @if($user->hostProfile)
            <div x-show="tab === 'host'" x-cloak>
                @php $host = $user->hostProfile; @endphp
                <div class="bg-mob-card border border-mob-border rounded-xl p-6">
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 text-sm">
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Business Name</p>
                            <p class="text-white">{{ $host->business_name ?? '--' }}</p>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Host Type</p>
                            <p class="text-white capitalize">{{ $host->host_type->value ?? '--' }}</p>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Verification Status</p>
                            @php
                                $verificationColors = [
                                    'approved' => 'text-mob-green bg-mob-green/10',
                                    'pending' => 'text-mob-amber bg-mob-amber/10',
                                    'rejected' => 'text-mob-red bg-mob-red/10',
                                ];
                                $verificationStatus = $host->verification_status->value;
                                $verificationClass = $verificationColors[$verificationStatus] ?? 'text-mob-dim bg-mob-elevated';
                            @endphp
                            <span class="inline-block px-2.5 py-0.5 rounded text-xs font-medium uppercase {{ $verificationClass }}">
                                {{ $verificationStatus }}
                            </span>
                        </div>
                        <div>
                            <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Document Type</p>
                            <p class="text-white uppercase">{{ $host->verification_document_type ?? '--' }}</p>
                        </div>
                        @if($host->verified_at)
                            <div>
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Verified At</p>
                                <p class="text-mob-green text-xs font-medium">{{ $host->verified_at->format('M j, Y \a\t g:i A') }}</p>
                            </div>
                        @endif
                        @if($host->bio)
                            <div class="sm:col-span-2 lg:col-span-3">
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Bio</p>
                                <p class="text-mob-muted">{{ $host->bio }}</p>
                            </div>
                        @endif
                        @if($host->admin_notes)
                            <div class="sm:col-span-2 lg:col-span-3">
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Admin Notes</p>
                                <p class="text-mob-muted">{{ $host->admin_notes }}</p>
                            </div>
                        @endif
                        @if($host->verification_document_url)
                            <div class="sm:col-span-2 lg:col-span-3">
                                <p class="text-mob-dim text-xs uppercase tracking-wider mb-1">Verification Document</p>
                                <a href="{{ $host->verification_document_url }}" target="_blank" rel="noopener noreferrer" class="text-mob-cyan text-xs hover:underline">
                                    View Document
                                </a>
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        @endif
    </div>
@endsection

@push('scripts')
    <script src="//unpkg.com/alpinejs" defer></script>
@endpush
