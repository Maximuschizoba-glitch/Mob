<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mob — {{ $c['hero_title'] ?? 'See What\'s Happening Now' }}</title>
    <meta name="description" content="{{ $c['hero_subtitle'] ?? 'Discover real-time events around you.' }}">
    <meta property="og:title" content="Mob — {{ $c['hero_title'] ?? 'See What\'s Happening Now' }}">
    <meta property="og:description" content="{{ $c['hero_subtitle'] ?? '' }}">
    <meta property="og:type" content="website">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        mob: {
                            bg: '#0A0E1A', card: '#111827', elevated: '#1F2937',
                            border: '#374151', cyan: '#00F0FF', magenta: '#EC4899',
                            purple: '#A855F7', green: '#10B981', amber: '#F59E0B',
                            text: '#F9FAFB', muted: '#9CA3AF', dim: '#6B7280',
                        },
                    },
                },
            },
        }
    </script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', -apple-system, sans-serif; }
        html { scroll-behavior: smooth; }
        .gradient-text { background: linear-gradient(135deg, #00F0FF, #A855F7, #EC4899); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
        .glow { box-shadow: 0 0 60px rgba(0, 240, 255, 0.12); }
        .gradient-border { position: relative; padding: 1px; border-radius: 16px; background: linear-gradient(135deg, rgba(0,240,255,0.2), rgba(168,85,247,0.2), rgba(236,72,153,0.2)); }
        .gradient-border-inner { background: #111827; border-radius: 15px; height: 100%; }
        .fade-in { opacity: 0; transform: translateY(24px); transition: opacity 0.7s ease, transform 0.7s ease; }
        .fade-in.visible { opacity: 1; transform: translateY(0); }
    </style>
</head>
<body class="bg-mob-bg text-mob-text overflow-x-hidden">

    <!-- NAV -->
    <nav class="fixed top-0 left-0 right-0 z-50 bg-mob-bg/80 backdrop-blur-xl border-b border-white/5">
        <div class="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
            <a href="#" class="text-mob-cyan font-extrabold text-2xl tracking-[0.2em]">MOB</a>
            <div class="hidden md:flex items-center gap-8">
                <a href="#features" class="text-mob-muted hover:text-white text-sm transition-colors">Features</a>
                <a href="#how-it-works" class="text-mob-muted hover:text-white text-sm transition-colors">How It Works</a>
                <a href="#about" class="text-mob-muted hover:text-white text-sm transition-colors">About</a>
            </div>
            <a href="{{ $c['playstore_url'] ?? '#' }}" class="bg-mob-cyan text-mob-bg font-bold px-5 py-2.5 rounded-xl text-sm hover:bg-mob-cyan/90 transition-all hover:shadow-lg hover:shadow-mob-cyan/20">
                Download App
            </a>
        </div>
    </nav>

    <!-- HERO -->
    <section class="pt-36 pb-24 px-6">
        <div class="max-w-6xl mx-auto text-center fade-in">
            <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-mob-cyan/10 border border-mob-cyan/20 text-mob-cyan text-sm font-medium mb-8">
                <span class="w-2 h-2 rounded-full bg-mob-cyan animate-pulse"></span>
                Live in Lagos
            </div>
            <h1 class="text-5xl md:text-6xl lg:text-7xl font-extrabold leading-[1.1] mb-6">
                <span class="gradient-text">{{ $c['hero_title'] ?? 'See What\'s Happening Now' }}</span>
            </h1>
            <p class="text-mob-muted text-lg md:text-xl max-w-2xl mx-auto mb-10 leading-relaxed">
                {{ $c['hero_subtitle'] ?? '' }}
            </p>
            <div class="flex flex-col sm:flex-row items-center justify-center gap-4 mb-16">
                <a href="{{ $c['appstore_url'] ?? '#' }}" class="flex items-center gap-3 bg-white text-black px-7 py-4 rounded-2xl font-bold hover:bg-gray-100 transition-all hover:scale-105">
                    <svg class="w-7 h-7" viewBox="0 0 24 24" fill="currentColor"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
                    <div class="text-left"><span class="text-[10px] block opacity-60">Download on the</span><span class="text-base">App Store</span></div>
                </a>
                <a href="{{ $c['playstore_url'] ?? '#' }}" class="flex items-center gap-3 bg-white text-black px-7 py-4 rounded-2xl font-bold hover:bg-gray-100 transition-all hover:scale-105">
                    <svg class="w-7 h-7" viewBox="0 0 24 24" fill="currentColor"><path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 01-.61-.92V2.734a1 1 0 01.609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-3.198l2.807 1.626a1 1 0 010 1.73l-2.808 1.626L15.206 12l2.492-2.491zM5.864 2.658L16.8 8.99l-2.302 2.302-8.634-8.634z"/></svg>
                    <div class="text-left"><span class="text-[10px] block opacity-60">Get it on</span><span class="text-base">Google Play</span></div>
                </a>
            </div>
            @if(!empty($c['hero_image']))
            <div class="max-w-sm mx-auto">
                <img src="{{ $c['hero_image'] }}" alt="Mob App" class="rounded-3xl glow w-full">
            </div>
            @endif
        </div>
    </section>

    <!-- FEATURES -->
    <section id="features" class="py-24 px-6">
        <div class="max-w-6xl mx-auto">
            <div class="text-center mb-16 fade-in">
                <h2 class="text-3xl md:text-5xl font-extrabold text-white mb-4">{{ $c['features_title'] ?? 'Features' }}</h2>
            </div>
            <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-5">
                @for($i = 1; $i <= 4; $i++)
                <div class="fade-in gradient-border">
                    <div class="gradient-border-inner p-7">
                        <div class="text-4xl mb-5">{{ $c["feature_{$i}_icon"] ?? '' }}</div>
                        <h3 class="text-white font-bold text-lg mb-3">{{ $c["feature_{$i}_title"] ?? '' }}</h3>
                        <p class="text-mob-muted text-sm leading-relaxed">{{ $c["feature_{$i}_desc"] ?? '' }}</p>
                    </div>
                </div>
                @endfor
            </div>
        </div>
    </section>

    <!-- HOW IT WORKS -->
    <section id="how-it-works" class="py-24 px-6 bg-gradient-to-b from-mob-card/30 to-transparent">
        <div class="max-w-3xl mx-auto">
            <div class="text-center mb-16 fade-in">
                <h2 class="text-3xl md:text-5xl font-extrabold text-white mb-4">{{ $c['how_title'] ?? 'How It Works' }}</h2>
            </div>
            <div class="space-y-10">
                @for($i = 1; $i <= 3; $i++)
                <div class="flex items-start gap-6 fade-in">
                    <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-mob-cyan/20 to-mob-purple/20 border border-mob-cyan/20 flex items-center justify-center flex-shrink-0">
                        <span class="text-mob-cyan font-extrabold text-lg">{{ $i }}</span>
                    </div>
                    <div class="pt-2">
                        <h3 class="text-white font-bold text-xl mb-2">{{ $c["step_{$i}_title"] ?? '' }}</h3>
                        <p class="text-mob-muted leading-relaxed">{{ $c["step_{$i}_desc"] ?? '' }}</p>
                    </div>
                </div>
                @endfor
            </div>
        </div>
    </section>

    <!-- TESTIMONIALS -->
    <section class="py-24 px-6">
        <div class="max-w-6xl mx-auto">
            <div class="text-center mb-16 fade-in">
                <h2 class="text-3xl md:text-5xl font-extrabold text-white mb-4">{{ $c['testimonials_title'] ?? 'What People Are Saying' }}</h2>
            </div>
            <div class="grid md:grid-cols-3 gap-6">
                @for($i = 1; $i <= 3; $i++)
                <div class="fade-in bg-mob-card rounded-2xl border border-mob-border p-7 hover:border-mob-cyan/20 transition-colors">
                    <div class="text-mob-cyan/40 text-5xl leading-none mb-3">&ldquo;</div>
                    <p class="text-mob-muted text-sm leading-relaxed mb-6">{{ $c["testimonial_{$i}_text"] ?? '' }}</p>
                    <div class="flex items-center gap-3 pt-4 border-t border-mob-border">
                        <div class="w-10 h-10 rounded-full bg-gradient-to-br from-mob-cyan/30 to-mob-purple/30 flex items-center justify-center text-white text-sm font-bold">
                            {{ strtoupper(substr($c["testimonial_{$i}_name"] ?? 'U', 0, 1)) }}
                        </div>
                        <div>
                            <p class="text-white text-sm font-semibold">{{ $c["testimonial_{$i}_name"] ?? '' }}</p>
                            <p class="text-mob-dim text-xs">{{ $c["testimonial_{$i}_role"] ?? '' }}</p>
                        </div>
                    </div>
                </div>
                @endfor
            </div>
        </div>
    </section>

    <!-- ABOUT -->
    <section id="about" class="py-24 px-6 bg-gradient-to-b from-mob-card/30 to-transparent">
        <div class="max-w-3xl mx-auto text-center fade-in">
            <h2 class="text-3xl md:text-5xl font-extrabold text-white mb-8">{{ $c['about_title'] ?? 'About Mob' }}</h2>
            <div class="text-mob-muted text-lg leading-relaxed [&_p]:mb-4 [&_strong]:text-white">
                {!! $c['about_text'] ?? '' !!}
            </div>
        </div>
    </section>

    <!-- DOWNLOAD CTA -->
    <section class="py-24 px-6">
        <div class="max-w-4xl mx-auto fade-in">
            <div class="relative bg-gradient-to-br from-mob-cyan/10 via-mob-purple/10 to-mob-magenta/10 border border-mob-border rounded-3xl p-12 md:p-16 text-center glow overflow-hidden">
                <div class="absolute inset-0 bg-gradient-to-br from-mob-cyan/5 via-transparent to-mob-magenta/5 rounded-3xl"></div>
                <div class="relative z-10">
                    <h2 class="text-3xl md:text-5xl font-extrabold text-white mb-4">{{ $c['cta_title'] ?? 'Ready to See What\'s Happening?' }}</h2>
                    <p class="text-mob-muted text-lg mb-10 max-w-xl mx-auto">{{ $c['cta_subtitle'] ?? '' }}</p>
                    <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
                        <a href="{{ $c['appstore_url'] ?? '#' }}" class="flex items-center gap-3 bg-white text-black px-7 py-4 rounded-2xl font-bold hover:bg-gray-100 transition-all hover:scale-105">
                            <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
                            App Store
                        </a>
                        <a href="{{ $c['playstore_url'] ?? '#' }}" class="flex items-center gap-3 bg-white text-black px-7 py-4 rounded-2xl font-bold hover:bg-gray-100 transition-all hover:scale-105">
                            <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor"><path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 01-.61-.92V2.734a1 1 0 01.609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-3.198l2.807 1.626a1 1 0 010 1.73l-2.808 1.626L15.206 12l2.492-2.491zM5.864 2.658L16.8 8.99l-2.302 2.302-8.634-8.634z"/></svg>
                            Google Play
                        </a>
                    </div>
                    @if(!empty($c['cta_image']))
                    <img src="{{ $c['cta_image'] }}" alt="Download Mob" class="mx-auto mt-12 max-w-xs rounded-2xl">
                    @endif
                </div>
            </div>
        </div>
    </section>

    <!-- FOOTER -->
    <footer class="border-t border-mob-border pt-16 pb-8 px-6">
        <div class="max-w-6xl mx-auto">
            <div class="grid md:grid-cols-4 gap-10 mb-12">
                <div class="md:col-span-2">
                    <h3 class="text-mob-cyan font-extrabold text-2xl tracking-[0.2em] mb-4">MOB</h3>
                    <p class="text-mob-muted text-sm leading-relaxed max-w-md">{{ $c['footer_description'] ?? '' }}</p>
                    <div class="flex items-center gap-4 mt-6">
                        @if(!empty($c['footer_instagram']))
                        <a href="{{ $c['footer_instagram'] }}" target="_blank" class="w-9 h-9 rounded-lg bg-mob-elevated flex items-center justify-center text-mob-muted hover:text-mob-cyan hover:bg-mob-cyan/10 transition-all">
                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z"/></svg>
                        </a>
                        @endif
                        @if(!empty($c['footer_twitter']))
                        <a href="{{ $c['footer_twitter'] }}" target="_blank" class="w-9 h-9 rounded-lg bg-mob-elevated flex items-center justify-center text-mob-muted hover:text-mob-cyan hover:bg-mob-cyan/10 transition-all">
                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
                        </a>
                        @endif
                        @if(!empty($c['footer_tiktok']))
                        <a href="{{ $c['footer_tiktok'] }}" target="_blank" class="w-9 h-9 rounded-lg bg-mob-elevated flex items-center justify-center text-mob-muted hover:text-mob-cyan hover:bg-mob-cyan/10 transition-all">
                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M19.59 6.69a4.83 4.83 0 01-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 01-2.88 2.5 2.89 2.89 0 01-2.89-2.89 2.89 2.89 0 012.89-2.89c.28 0 .54.04.79.1V9.01a6.27 6.27 0 00-.79-.05 6.34 6.34 0 00-6.34 6.34 6.34 6.34 0 006.34 6.34 6.34 6.34 0 006.34-6.34V8.75a8.18 8.18 0 004.76 1.52V6.84a4.86 4.86 0 01-1-.15z"/></svg>
                        </a>
                        @endif
                        @if(!empty($c['footer_email']))
                        <a href="mailto:{{ $c['footer_email'] }}" class="w-9 h-9 rounded-lg bg-mob-elevated flex items-center justify-center text-mob-muted hover:text-mob-cyan hover:bg-mob-cyan/10 transition-all">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                        </a>
                        @endif
                    </div>
                </div>
                <div>
                    <h4 class="text-white font-semibold text-sm mb-4">Product</h4>
                    <div class="space-y-3">
                        <a href="#features" class="block text-mob-muted text-sm hover:text-white transition-colors">Features</a>
                        <a href="#how-it-works" class="block text-mob-muted text-sm hover:text-white transition-colors">How It Works</a>
                        <a href="#about" class="block text-mob-muted text-sm hover:text-white transition-colors">About</a>
                    </div>
                </div>
                <div>
                    <h4 class="text-white font-semibold text-sm mb-4">Legal</h4>
                    <div class="space-y-3">
                        <a href="{{ route('privacy') }}" class="block text-mob-muted text-sm hover:text-white transition-colors">Privacy Policy</a>
                        <a href="{{ route('terms') }}" class="block text-mob-muted text-sm hover:text-white transition-colors">Terms of Service</a>
                    </div>
                </div>
            </div>
            <div class="border-t border-mob-border pt-8 flex flex-col md:flex-row items-center justify-between gap-4">
                <p class="text-mob-dim text-xs">&copy; {{ date('Y') }} Mob. All rights reserved.</p>
                <p class="text-mob-dim text-xs">Powered by <span class="text-mob-muted font-medium">{{ $c['company_name'] ?? 'Buuk Tech Solutions Ltd' }}</span></p>
            </div>
        </div>
    </footer>

    <script>
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) entry.target.classList.add('visible');
            });
        }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });
        document.querySelectorAll('.fade-in').forEach(el => observer.observe(el));
    </script>
</body>
</html>
