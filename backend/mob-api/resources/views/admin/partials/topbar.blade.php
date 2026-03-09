<header class="sticky top-0 z-20 bg-mob-bg/80 backdrop-blur-lg border-b border-mob-border px-6 py-4">
    <div class="flex items-center justify-between">
        <div>
            <h1 class="text-lg font-semibold text-white">@yield('page-title', 'Dashboard')</h1>
            @hasSection('page-subtitle')
                <p class="text-sm text-mob-dim">@yield('page-subtitle')</p>
            @endif
        </div>
        <div class="flex items-center gap-4">
            <div class="text-sm text-mob-dim">
                {{ now()->format('D, M j, Y') }}
            </div>
        </div>
    </div>
</header>
