<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title }} — Mob</title>
    <meta name="description" content="{{ $title }} for Mob - Real-time city discovery app for Lagos">

    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        mob: {
                            bg: '#0A0E1A',
                            card: '#111827',
                            border: '#374151',
                            cyan: '#00F0FF',
                            text: '#F9FAFB',
                            muted: '#9CA3AF',
                            dim: '#6B7280'
                        }
                    }
                }
            }
        }
    </script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
        html { scroll-behavior: smooth; }
        .gradient-text {
            background: linear-gradient(135deg, #00F0FF, #A855F7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .prose h2 { font-size: 1.5rem; font-weight: 700; color: #F9FAFB; margin-top: 2rem; margin-bottom: 1rem; }
        .prose h3 { font-size: 1.25rem; font-weight: 600; color: #F9FAFB; margin-top: 1.5rem; margin-bottom: 0.75rem; }
        .prose p { color: #9CA3AF; line-height: 1.75; margin-bottom: 1rem; }
        .prose ul, .prose ol { color: #9CA3AF; margin-bottom: 1rem; padding-left: 1.5rem; }
        .prose li { margin-bottom: 0.25rem; }
        .prose a { color: #00F0FF; text-decoration: none; }
        .prose a:hover { text-decoration: underline; }
        .prose strong { color: #F9FAFB; }
        .prose table { width: 100%; border-collapse: collapse; margin: 1rem 0; }
        .prose th, .prose td { border: 1px solid #374151; padding: 0.5rem 1rem; text-align: left; color: #9CA3AF; }
        .prose th { background: #1F2937; color: #F9FAFB; font-weight: 600; }
    </style>
</head>
<body class="bg-mob-bg text-white antialiased">

    {{-- NAVBAR --}}
    <nav class="fixed top-0 w-full z-50 bg-mob-bg/80 backdrop-blur-xl border-b border-mob-border/50">
        <div class="max-w-4xl mx-auto px-6 py-4 flex items-center justify-between">
            <a href="{{ route('home') }}" class="text-mob-cyan font-bold text-2xl tracking-widest">MOB</a>
            <a href="{{ route('home') }}" class="text-sm text-mob-muted hover:text-white transition-colors">&larr; Back to Home</a>
        </div>
    </nav>

    {{-- CONTENT --}}
    <main class="pt-28 pb-20 px-6">
        <div class="max-w-4xl mx-auto">
            <h1 class="text-3xl sm:text-4xl font-bold mb-8">
                <span class="gradient-text">{{ $title }}</span>
            </h1>

            <div class="bg-mob-card border border-mob-border rounded-2xl p-8 sm:p-12">
                <div class="prose max-w-none">
                    {!! $content !!}
                </div>
            </div>
        </div>
    </main>

    {{-- FOOTER --}}
    <footer class="border-t border-mob-border py-8 px-6">
        <div class="max-w-4xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
            <div class="flex items-center gap-6">
                <span class="text-mob-cyan font-bold tracking-widest">MOB</span>
                <a href="{{ route('privacy') }}" class="text-xs text-mob-muted hover:text-white transition-colors {{ $title === 'Privacy Policy' ? 'text-white' : '' }}">Privacy Policy</a>
                <a href="{{ route('terms') }}" class="text-xs text-mob-muted hover:text-white transition-colors {{ $title === 'Terms of Service' ? 'text-white' : '' }}">Terms of Service</a>
            </div>
            <p class="text-xs text-mob-dim">&copy; {{ date('Y') }} {{ $footer['company_name'] ?? 'Mob' }}. All rights reserved.</p>
        </div>
    </footer>

</body>
</html>
