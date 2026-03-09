<aside class="fixed left-0 top-0 w-64 h-full bg-mob-card border-r border-mob-border z-30 flex flex-col">
    <div class="px-6 py-5 border-b border-mob-border">
        <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-3">
            <span class="text-mob-cyan font-bold text-2xl tracking-widest">MOB</span>
            <span class="text-mob-dim text-xs uppercase tracking-wider">Admin</span>
        </a>
    </div>

    <nav class="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        @php
            $currentRoute = request()->route()?->getName() ?? '';
            $nav = [
                ['route' => 'admin.dashboard', 'match' => 'admin.dashboard', 'icon' => 'grid', 'label' => 'Dashboard'],
                ['route' => 'admin.users.index', 'match' => 'admin.users', 'icon' => 'users', 'label' => 'Users'],
                ['route' => 'admin.verifications.index', 'match' => 'admin.verifications', 'icon' => 'shield-check', 'label' => 'Verifications'],
                ['route' => 'admin.happenings.index', 'match' => 'admin.happenings', 'icon' => 'zap', 'label' => 'Happenings'],
                ['route' => 'admin.escrow.index', 'match' => 'admin.escrow', 'icon' => 'lock', 'label' => 'Escrow', 'admin_only' => true],
                ['route' => 'admin.tickets.index', 'match' => 'admin.tickets', 'icon' => 'ticket', 'label' => 'Tickets'],
                ['route' => 'admin.reports.index', 'match' => 'admin.reports', 'icon' => 'flag', 'label' => 'Reports'],
                ['route' => 'admin.content.landing', 'match' => 'admin.content', 'icon' => 'globe', 'label' => 'Landing Page'],
                ['route' => 'admin.content.legal', 'match' => 'admin.content.legal', 'icon' => 'file-text', 'label' => 'Legal Pages'],
                ['route' => 'admin.settings.index', 'match' => 'admin.settings', 'icon' => 'settings', 'label' => 'Settings', 'admin_only' => true],
            ];
        @endphp

        @foreach($nav as $item)
            @if(!isset($item['admin_only']) || auth()->user()->role === \App\Enums\UserRole::ADMIN)
                @php
                    $isActive = str_starts_with($currentRoute, $item['match']);
                @endphp
                <a href="{{ route($item['route']) }}"
                   class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors {{ $isActive ? 'bg-mob-cyan/10 text-mob-cyan' : 'text-mob-muted hover:text-white hover:bg-mob-elevated' }}">
                    <span class="w-5 h-5 flex items-center justify-center">
                        @include('admin.icons.' . $item['icon'])
                    </span>
                    <span>{{ $item['label'] }}</span>
                </a>
            @endif
        @endforeach
    </nav>

    <div class="px-4 py-4 border-t border-mob-border">
        <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-sm font-bold">
                {{ strtoupper(substr(auth()->user()->name, 0, 1)) }}
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-sm text-white truncate">{{ auth()->user()->name }}</p>
                <p class="text-xs text-mob-dim capitalize">{{ auth()->user()->role->value }}</p>
            </div>
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="text-mob-dim hover:text-mob-red transition-colors" title="Logout">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                </button>
            </form>
        </div>
    </div>
</aside>
