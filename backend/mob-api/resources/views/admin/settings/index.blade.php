@extends('admin.layouts.app')

@section('title', 'Settings')
@section('page-title', 'Admin Settings')
@section('page-subtitle', $counts['total'] . ' team ' . Str::plural('member', $counts['total']))

@section('content')
    <!-- Stats Row -->
    <div class="grid grid-cols-2 md:grid-cols-3 gap-3 mb-6">
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Admins</p>
            <p class="text-lg font-bold text-mob-cyan">{{ $counts['admins'] }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Full access</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Moderators</p>
            <p class="text-lg font-bold text-mob-amber">{{ $counts['moderators'] }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Limited access</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3 col-span-2 md:col-span-1">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Total Team</p>
            <p class="text-lg font-bold text-white">{{ $counts['total'] }}</p>
            <p class="text-mob-dim text-[10px] mt-0.5">Admin panel users</p>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Left Column: Team Members -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Admin Users Table -->
            <div class="bg-mob-card border border-mob-border rounded-xl overflow-hidden">
                <div class="px-5 py-4 border-b border-mob-border flex items-center justify-between">
                    <h3 class="text-sm font-semibold text-white">Team Members</h3>
                    <span class="text-mob-dim text-xs">{{ $counts['total'] }} {{ Str::plural('member', $counts['total']) }}</span>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-sm text-left">
                        <thead>
                            <tr class="border-b border-mob-border">
                                <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">User</th>
                                <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Role</th>
                                <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Joined</th>
                                <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-mob-border">
                            @forelse($admins as $admin)
                                @php
                                    $roleColors = [
                                        'admin' => 'text-mob-cyan bg-mob-cyan/10',
                                        'moderator' => 'text-mob-amber bg-mob-amber/10',
                                    ];
                                    $avatarColors = [
                                        'admin' => 'text-mob-cyan',
                                        'moderator' => 'text-mob-amber',
                                    ];
                                @endphp
                                <tr class="hover:bg-mob-elevated/50 transition-colors">
                                    <td class="px-5 py-3.5">
                                        <div class="flex items-center gap-3">
                                            <div class="w-8 h-8 rounded-full bg-mob-elevated flex items-center justify-center {{ $avatarColors[$admin->role->value] ?? 'text-mob-cyan' }} text-xs font-bold shrink-0">
                                                {{ strtoupper(substr($admin->name, 0, 1)) }}
                                            </div>
                                            <div class="min-w-0">
                                                <div class="flex items-center gap-2">
                                                    <p class="text-white text-sm font-medium truncate">{{ $admin->name }}</p>
                                                    @if($admin->id === auth()->id())
                                                        <span class="text-[9px] px-1.5 py-0.5 rounded-full bg-mob-cyan/15 text-mob-cyan font-semibold uppercase">You</span>
                                                    @endif
                                                </div>
                                                <p class="text-mob-dim text-xs truncate">{{ $admin->email }}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-5 py-3.5">
                                        <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase {{ $roleColors[$admin->role->value] ?? 'text-mob-dim bg-mob-elevated' }}">
                                            {{ $admin->role->value }}
                                        </span>
                                    </td>
                                    <td class="px-5 py-3.5 text-mob-dim text-xs">
                                        {{ $admin->created_at->format('M j, Y') }}
                                    </td>
                                    <td class="px-5 py-3.5 text-right">
                                        @if($admin->id === auth()->id())
                                            <span class="text-mob-dim text-xs">Current session</span>
                                        @else
                                            <form action="{{ route('admin.settings.removeAdmin', $admin) }}" method="POST" class="inline">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit"
                                                        class="text-mob-red hover:text-white text-xs font-medium transition-colors cursor-pointer"
                                                        onclick="return confirm('Remove {{ $admin->name }} as {{ $admin->role->value }}? They will lose admin panel access immediately.')">
                                                    Remove
                                                </button>
                                            </form>
                                        @endif
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="4" class="px-5 py-12 text-center">
                                        <p class="text-mob-dim text-sm">No admin users found.</p>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Add Team Member -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Add Team Member</h3>
                    <p class="text-mob-dim text-xs mt-0.5">Create a new admin or moderator account</p>
                </div>
                <form action="{{ route('admin.settings.createAdmin') }}" method="POST" class="p-5">
                    @csrf
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-5">
                        <div>
                            <label for="name" class="block text-mob-dim text-xs uppercase tracking-wider mb-2">
                                Full Name <span class="text-mob-red">*</span>
                            </label>
                            <input
                                type="text"
                                id="name"
                                name="name"
                                value="{{ old('name') }}"
                                required
                                placeholder="Enter full name"
                                class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none transition-colors"
                            />
                            @error('name')
                                <p class="text-mob-red text-xs mt-1">{{ $message }}</p>
                            @enderror
                        </div>
                        <div>
                            <label for="email" class="block text-mob-dim text-xs uppercase tracking-wider mb-2">
                                Email Address <span class="text-mob-red">*</span>
                            </label>
                            <input
                                type="email"
                                id="email"
                                name="email"
                                value="{{ old('email') }}"
                                required
                                placeholder="admin@mob.app"
                                class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none transition-colors"
                            />
                            @error('email')
                                <p class="text-mob-red text-xs mt-1">{{ $message }}</p>
                            @enderror
                        </div>
                        <div>
                            <label for="password" class="block text-mob-dim text-xs uppercase tracking-wider mb-2">
                                Password <span class="text-mob-red">*</span>
                            </label>
                            <input
                                type="password"
                                id="password"
                                name="password"
                                required
                                minlength="8"
                                placeholder="Minimum 8 characters"
                                class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none transition-colors"
                            />
                            @error('password')
                                <p class="text-mob-red text-xs mt-1">{{ $message }}</p>
                            @enderror
                        </div>
                        <div>
                            <label for="password_confirmation" class="block text-mob-dim text-xs uppercase tracking-wider mb-2">
                                Confirm Password <span class="text-mob-red">*</span>
                            </label>
                            <input
                                type="password"
                                id="password_confirmation"
                                name="password_confirmation"
                                required
                                minlength="8"
                                placeholder="Repeat password"
                                class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none transition-colors"
                            />
                        </div>
                    </div>

                    <!-- Role Selection -->
                    <div class="mb-5">
                        <label class="block text-mob-dim text-xs uppercase tracking-wider mb-3">
                            Role <span class="text-mob-red">*</span>
                        </label>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                            <label class="relative cursor-pointer">
                                <input type="radio" name="role" value="moderator" class="peer sr-only" {{ old('role', 'moderator') === 'moderator' ? 'checked' : '' }}>
                                <div class="p-4 rounded-xl border border-mob-border bg-mob-elevated/30 peer-checked:border-mob-amber/50 peer-checked:bg-mob-amber/5 transition-colors">
                                    <div class="flex items-center gap-2 mb-1.5">
                                        <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase text-mob-amber bg-mob-amber/10">Moderator</span>
                                    </div>
                                    <p class="text-mob-dim text-xs leading-relaxed">
                                        Can manage users, happenings, verifications, reports, and tickets. Cannot access escrow, settings, or delete users.
                                    </p>
                                </div>
                            </label>
                            <label class="relative cursor-pointer">
                                <input type="radio" name="role" value="admin" class="peer sr-only" {{ old('role') === 'admin' ? 'checked' : '' }}>
                                <div class="p-4 rounded-xl border border-mob-border bg-mob-elevated/30 peer-checked:border-mob-cyan/50 peer-checked:bg-mob-cyan/5 transition-colors">
                                    <div class="flex items-center gap-2 mb-1.5">
                                        <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase text-mob-cyan bg-mob-cyan/10">Admin</span>
                                    </div>
                                    <p class="text-mob-dim text-xs leading-relaxed">
                                        Full access to everything. Can manage escrow payouts, system settings, delete users, and manage other admins.
                                    </p>
                                </div>
                            </label>
                        </div>
                        @error('role')
                            <p class="text-mob-red text-xs mt-2">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="flex items-center justify-between pt-4 border-t border-mob-border">
                        <p class="text-mob-dim text-xs">Account will be immediately active after creation.</p>
                        <button type="submit"
                                class="px-6 py-2.5 text-sm font-medium rounded-lg bg-mob-cyan/10 text-mob-cyan border border-mob-cyan/30 hover:bg-mob-cyan/20 transition-colors cursor-pointer"
                                onclick="return confirm('Create this account? They will be able to log into the admin panel immediately.')">
                            Create Account
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Right Column: Sidebar -->
        <div class="space-y-6">
            <!-- Role Permissions -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Role Permissions</h3>
                </div>
                <div class="p-5 space-y-5">
                    <!-- Admin -->
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase text-mob-cyan bg-mob-cyan/10">Admin</span>
                        </div>
                        <ul class="space-y-1.5">
                            @php
                                $adminPerms = [
                                    'Dashboard & analytics',
                                    'Manage users (suspend, delete)',
                                    'Review verifications',
                                    'Moderate happenings',
                                    'Process reports',
                                    'View tickets',
                                    'Approve escrow payouts',
                                    'Force refunds',
                                    'Manage admin accounts',
                                    'System settings',
                                ];
                            @endphp
                            @foreach($adminPerms as $perm)
                                <li class="flex items-center gap-2 text-xs text-mob-muted">
                                    <svg class="w-3.5 h-3.5 text-mob-cyan shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                                    {{ $perm }}
                                </li>
                            @endforeach
                        </ul>
                    </div>

                    <div class="border-t border-mob-border"></div>

                    <!-- Moderator -->
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="inline-block px-2 py-0.5 rounded text-[10px] font-medium uppercase text-mob-amber bg-mob-amber/10">Moderator</span>
                        </div>
                        <ul class="space-y-1.5">
                            @php
                                $modPerms = [
                                    ['text' => 'Dashboard & analytics', 'allowed' => true],
                                    ['text' => 'Manage users (suspend only)', 'allowed' => true],
                                    ['text' => 'Review verifications', 'allowed' => true],
                                    ['text' => 'Moderate happenings', 'allowed' => true],
                                    ['text' => 'Process reports', 'allowed' => true],
                                    ['text' => 'View tickets', 'allowed' => true],
                                    ['text' => 'Escrow & payouts', 'allowed' => false],
                                    ['text' => 'Delete users', 'allowed' => false],
                                    ['text' => 'Admin accounts', 'allowed' => false],
                                    ['text' => 'System settings', 'allowed' => false],
                                ];
                            @endphp
                            @foreach($modPerms as $perm)
                                <li class="flex items-center gap-2 text-xs {{ $perm['allowed'] ? 'text-mob-muted' : 'text-mob-dim line-through' }}">
                                    @if($perm['allowed'])
                                        <svg class="w-3.5 h-3.5 text-mob-amber shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                                    @else
                                        <svg class="w-3.5 h-3.5 text-mob-dim shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                                    @endif
                                    {{ $perm['text'] }}
                                </li>
                            @endforeach
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Security Info -->
            <div class="bg-mob-card border border-mob-border rounded-xl">
                <div class="px-5 py-4 border-b border-mob-border">
                    <h3 class="text-sm font-semibold text-white">Security Notes</h3>
                </div>
                <div class="p-5 space-y-3">
                    <div class="flex items-start gap-2.5">
                        <svg class="w-4 h-4 text-mob-amber shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/></svg>
                        <p class="text-mob-dim text-xs leading-relaxed">Removing a team member revokes their admin access and API tokens immediately.</p>
                    </div>
                    <div class="flex items-start gap-2.5">
                        <svg class="w-4 h-4 text-mob-cyan shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
                        <p class="text-mob-dim text-xs leading-relaxed">At least one admin account must exist at all times. You cannot remove yourself.</p>
                    </div>
                    <div class="flex items-start gap-2.5">
                        <svg class="w-4 h-4 text-mob-green shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/></svg>
                        <p class="text-mob-dim text-xs leading-relaxed">New accounts can log in immediately. Share credentials securely.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
