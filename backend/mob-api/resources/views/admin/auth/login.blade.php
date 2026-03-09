<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login — Mob</title>
    @vite(['resources/css/admin.css'])
</head>
<body class="bg-mob-bg min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-sm">
        <div class="text-center mb-8">
            <h1 class="text-mob-cyan font-bold text-3xl tracking-widest mb-2">MOB</h1>
            <p class="text-mob-dim text-sm">Admin Panel</p>
        </div>

        <div class="bg-mob-card rounded-2xl border border-mob-border p-8">
            <h2 class="text-white text-lg font-semibold mb-6">Sign in to continue</h2>

            @if($errors->any())
                <div class="mb-4 px-4 py-3 rounded-lg bg-mob-red/10 border border-mob-red/20 text-mob-red text-sm">
                    {{ $errors->first() }}
                </div>
            @endif

            <form method="POST" action="{{ route('admin.login.submit') }}">
                @csrf

                <div class="mb-4">
                    <label class="block text-mob-muted text-sm mb-2">Email</label>
                    <input type="email" name="email" value="{{ old('email') }}" required autofocus
                           class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-3 text-white text-sm placeholder-mob-dim focus:border-mob-cyan focus:ring-1 focus:ring-mob-cyan focus:outline-none"
                           placeholder="admin@example.com">
                </div>

                <div class="mb-6">
                    <label class="block text-mob-muted text-sm mb-2">Password</label>
                    <input type="password" name="password" required
                           class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-3 text-white text-sm placeholder-mob-dim focus:border-mob-cyan focus:ring-1 focus:ring-mob-cyan focus:outline-none"
                           placeholder="••••••••">
                </div>

                <div class="flex items-center justify-between mb-6">
                    <label class="flex items-center gap-2 cursor-pointer">
                        <input type="checkbox" name="remember" class="w-4 h-4 rounded border-mob-border bg-mob-elevated text-mob-cyan focus:ring-mob-cyan">
                        <span class="text-mob-dim text-sm">Remember me</span>
                    </label>
                </div>

                <button type="submit" class="w-full bg-mob-cyan text-mob-bg font-semibold py-3 rounded-lg hover:bg-mob-cyan/90 transition-colors text-sm cursor-pointer">
                    Sign In
                </button>
            </form>
        </div>

        <p class="text-center text-mob-dim text-xs mt-6">Mob Admin Panel v1.0</p>
    </div>
</body>
</html>
