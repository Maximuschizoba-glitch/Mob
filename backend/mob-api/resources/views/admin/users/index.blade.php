@extends('admin.layouts.app')

@section('title', 'Users')
@section('page-title', 'Users')
@section('page-subtitle', number_format($stats['total']) . ' total users')

@section('content')
    <!-- Stats Row -->
    <div class="grid grid-cols-2 md:grid-cols-5 gap-3 mb-6">
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Total</p>
            <p class="text-lg font-bold text-white">{{ number_format($stats['total']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Users</p>
            <p class="text-lg font-bold text-white">{{ number_format($stats['users']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Hosts</p>
            <p class="text-lg font-bold text-mob-purple">{{ number_format($stats['hosts']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Admins</p>
            <p class="text-lg font-bold text-mob-cyan">{{ number_format($stats['admins']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Suspended</p>
            <p class="text-lg font-bold text-mob-red">{{ number_format($stats['suspended']) }}</p>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-mob-card border border-mob-border rounded-xl p-4 mb-6">
        <form method="GET" action="{{ route('admin.users.index') }}" class="flex flex-wrap items-center gap-3">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Search name, email, phone..."
                   class="flex-1 min-w-[200px] bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none">
            <select name="role" class="bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white focus:border-mob-cyan focus:outline-none">
                <option value="">All Roles</option>
                @foreach(\App\Enums\UserRole::cases() as $role)
                    <option value="{{ $role->value }}" {{ request('role') === $role->value ? 'selected' : '' }}>{{ ucfirst($role->value) }}</option>
                @endforeach
            </select>
            <select name="status" class="bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white focus:border-mob-cyan focus:outline-none">
                <option value="">All Status</option>
                <option value="active" {{ request('status') === 'active' ? 'selected' : '' }}>Active</option>
                <option value="suspended" {{ request('status') === 'suspended' ? 'selected' : '' }}>Suspended</option>
            </select>
            <button type="submit" class="bg-mob-cyan text-mob-bg px-5 py-2.5 rounded-lg text-sm font-medium hover:bg-mob-cyan/90 transition-colors cursor-pointer">
                Filter
            </button>
            @if(request()->hasAny(['search', 'role', 'status']))
                <a href="{{ route('admin.users.index') }}" class="px-4 py-2.5 bg-mob-elevated text-mob-muted text-sm font-medium rounded-lg hover:text-white transition-colors">
                    Clear
                </a>
            @endif
        </form>
    </div>

    <!-- Users Table -->
    <div class="bg-mob-card border border-mob-border rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left">
                <thead>
                    <tr class="border-b border-mob-border">
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">User</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Phone</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Role</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Status</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Joined</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-mob-border">
                    @forelse($users as $user)
                        <tr class="hover:bg-mob-elevated/50 transition-colors">
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-sm font-bold shrink-0">
                                        {{ strtoupper(substr($user->name, 0, 1)) }}
                                    </div>
                                    <div class="min-w-0">
                                        <p class="text-white text-sm font-medium truncate max-w-[200px]">{{ $user->name }}</p>
                                        <p class="text-mob-dim text-xs truncate max-w-[200px]">{{ $user->email }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-3.5 text-mob-muted text-sm">{{ $user->phone ?? '--' }}</td>
                            <td class="px-5 py-3.5">
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
                                <span class="inline-block px-2 py-0.5 rounded text-xs font-medium uppercase {{ $roleClass }}">
                                    {{ $user->role->value }}
                                </span>
                            </td>
                            <td class="px-5 py-3.5">
                                @if($user->isSuspended())
                                    <span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-mob-red/15 text-mob-red">Suspended</span>
                                @else
                                    <span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-mob-green/15 text-mob-green">Active</span>
                                @endif
                            </td>
                            <td class="px-5 py-3.5 text-mob-dim text-xs">{{ $user->created_at->format('M j, Y') }}</td>
                            <td class="px-5 py-3.5 text-right">
                                <a href="{{ route('admin.users.show', $user) }}" class="text-mob-cyan hover:text-white text-xs font-medium transition-colors">
                                    View
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-5 py-12 text-center">
                                <p class="text-mob-dim text-sm">No users found.</p>
                                @if(request()->hasAny(['search', 'role', 'status']))
                                    <a href="{{ route('admin.users.index') }}" class="text-mob-cyan text-sm hover:underline mt-1 inline-block">Clear filters</a>
                                @endif
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($users->hasPages())
            <div class="px-5 py-4 border-t border-mob-border">
                {{ $users->links() }}
            </div>
        @endif
    </div>
@endsection
