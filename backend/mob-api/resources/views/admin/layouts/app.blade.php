<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin') — Mob</title>
    @vite(['resources/css/admin.css'])
    <style>
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: #0A0E1A; }
        ::-webkit-scrollbar-thumb { background: #374151; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #4B5563; }
        *:focus-visible { outline: 2px solid #00F0FF; outline-offset: 2px; }
    </style>
    @stack('styles')
</head>
<body class="bg-mob-bg text-mob-text min-h-screen">
    <div class="flex min-h-screen">
        @include('admin.partials.sidebar')

        <div class="flex-1 ml-64">
            @include('admin.partials.topbar')

            <main class="p-6">
                @if(session('success'))
                    <div class="mb-6 px-4 py-3 rounded-lg bg-mob-green/10 border border-mob-green/20 text-mob-green text-sm">
                        {{ session('success') }}
                    </div>
                @endif
                @if(session('error'))
                    <div class="mb-6 px-4 py-3 rounded-lg bg-mob-red/10 border border-mob-red/20 text-mob-red text-sm">
                        {{ session('error') }}
                    </div>
                @endif

                @yield('content')
            </main>
        </div>
    </div>

    @stack('scripts')
</body>
</html>
