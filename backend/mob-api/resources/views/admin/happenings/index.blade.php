@extends('admin.layouts.app')

@section('title', 'Happenings')
@section('page-title', 'Happenings')
@section('page-subtitle', number_format($stats['total']) . ' total happenings')

@section('content')
    <!-- Stats Row -->
    <div class="grid grid-cols-2 md:grid-cols-6 gap-3 mb-6">
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Total</p>
            <p class="text-lg font-bold text-white">{{ number_format($stats['total']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Active</p>
            <p class="text-lg font-bold text-mob-green">{{ number_format($stats['active']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Completed</p>
            <p class="text-lg font-bold text-mob-cyan">{{ number_format($stats['completed']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Expired</p>
            <p class="text-lg font-bold text-mob-dim">{{ number_format($stats['expired']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Hidden</p>
            <p class="text-lg font-bold text-mob-red">{{ number_format($stats['hidden']) }}</p>
        </div>
        <div class="bg-mob-card border border-mob-border rounded-xl px-4 py-3">
            <p class="text-mob-dim text-[10px] uppercase tracking-wider">Ticketed</p>
            <p class="text-lg font-bold text-mob-purple">{{ number_format($stats['ticketed']) }}</p>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-mob-card border border-mob-border rounded-xl p-4 mb-6">
        <form method="GET" action="{{ route('admin.happenings.index') }}" class="flex flex-wrap items-center gap-3">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Search title or host name..."
                   class="flex-1 min-w-[200px] bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none">

            <select name="status" class="bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white focus:border-mob-cyan focus:outline-none">
                <option value="">All Statuses</option>
                @foreach(\App\Enums\HappeningStatus::cases() as $statusEnum)
                    <option value="{{ $statusEnum->value }}" {{ request('status') === $statusEnum->value ? 'selected' : '' }}>
                        {{ ucfirst($statusEnum->value) }}
                    </option>
                @endforeach
            </select>

            <select name="category" class="bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white focus:border-mob-cyan focus:outline-none">
                <option value="">All Categories</option>
                @foreach(\App\Enums\HappeningCategory::cases() as $category)
                    <option value="{{ $category->value }}" {{ request('category') === $category->value ? 'selected' : '' }}>
                        {{ str_replace('_', ' ', ucwords($category->value, '_')) }}
                    </option>
                @endforeach
            </select>

            <select name="type" class="bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white focus:border-mob-cyan focus:outline-none">
                <option value="">All Types</option>
                @foreach(\App\Enums\HappeningType::cases() as $type)
                    <option value="{{ $type->value }}" {{ request('type') === $type->value ? 'selected' : '' }}>
                        {{ ucfirst($type->value) }}
                    </option>
                @endforeach
            </select>

            <select name="ticketed" class="bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white focus:border-mob-cyan focus:outline-none">
                <option value="">All Ticket Types</option>
                <option value="yes" {{ request('ticketed') === 'yes' ? 'selected' : '' }}>Ticketed</option>
                <option value="no" {{ request('ticketed') === 'no' ? 'selected' : '' }}>Free</option>
            </select>

            <button type="submit" class="bg-mob-cyan text-mob-bg px-5 py-2.5 rounded-lg text-sm font-medium hover:bg-mob-cyan/90 transition-colors cursor-pointer">
                Filter
            </button>
            @if(request()->hasAny(['search', 'status', 'category', 'type', 'ticketed']))
                <a href="{{ route('admin.happenings.index') }}" class="px-4 py-2.5 bg-mob-elevated text-mob-muted text-sm font-medium rounded-lg hover:text-white transition-colors">
                    Clear
                </a>
            @endif
        </form>
    </div>

    <!-- Happenings Table -->
    <div class="bg-mob-card border border-mob-border rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left">
                <thead>
                    <tr class="border-b border-mob-border">
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Title</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Host</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Category</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Type</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Status</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Tickets</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider">Created</th>
                        <th class="px-5 py-3.5 text-xs font-medium text-mob-dim uppercase tracking-wider text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-mob-border">
                    @forelse($happenings as $happening)
                        @php
                            $displayStatus = $happening->getDisplayStatus();
                            $statusColors = [
                                'live'     => 'text-mob-green bg-mob-green/10',
                                'upcoming' => 'text-mob-cyan bg-mob-cyan/10',
                                'expired'  => 'text-mob-dim bg-mob-elevated',
                                'hidden'   => 'text-mob-red bg-mob-red/10',
                                'ended'    => 'text-mob-dim bg-mob-elevated',
                            ];
                            $categoryColors = [
                                'party_nightlife'   => 'text-mob-magenta bg-mob-magenta/10',
                                'food_drinks'       => 'text-mob-amber bg-mob-amber/10',
                                'hangouts_social'   => 'text-mob-green bg-mob-green/10',
                                'music_performance' => 'text-mob-purple bg-mob-purple/10',
                                'games_activities'  => 'text-blue-400 bg-blue-400/10',
                                'art_culture'       => 'text-mob-cyan bg-mob-cyan/10',
                                'study_work'        => 'text-indigo-400 bg-indigo-400/10',
                                'popups_street'     => 'text-orange-400 bg-orange-400/10',
                            ];
                            $catValue = $happening->category->value;
                        @endphp
                        <tr class="hover:bg-mob-elevated/50 transition-colors">
                            <td class="px-5 py-3.5">
                                <a href="{{ route('admin.happenings.show', $happening) }}" class="text-white hover:text-mob-cyan text-sm font-medium transition-colors truncate block max-w-[220px]">
                                    {{ $happening->title }}
                                </a>
                            </td>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-2">
                                    <div class="w-6 h-6 rounded-full bg-mob-elevated flex items-center justify-center text-mob-cyan text-[10px] font-bold shrink-0">
                                        {{ strtoupper(substr($happening->user->name ?? '?', 0, 1)) }}
                                    </div>
                                    <span class="text-mob-muted text-sm truncate max-w-[120px]">{{ $happening->user->name ?? 'Unknown' }}</span>
                                </div>
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="inline-block text-xs px-2 py-0.5 rounded font-medium {{ $categoryColors[$catValue] ?? 'text-mob-dim bg-mob-elevated' }}">
                                    {{ str_replace('_', ' ', ucwords($catValue, '_')) }}
                                </span>
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="text-mob-muted text-xs capitalize">{{ $happening->type->value }}</span>
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="inline-block px-2 py-0.5 rounded text-xs font-medium uppercase {{ $statusColors[$displayStatus] ?? 'text-mob-dim bg-mob-elevated' }}">
                                    {{ $displayStatus }}
                                </span>
                            </td>
                            <td class="px-5 py-3.5">
                                @if($happening->is_ticketed)
                                    <span class="text-mob-purple text-sm font-medium">{{ $happening->tickets_sold ?? 0 }}<span class="text-mob-dim font-normal">/{{ $happening->ticket_quantity ?? '∞' }}</span></span>
                                @else
                                    <span class="text-mob-dim text-xs">Free</span>
                                @endif
                            </td>
                            <td class="px-5 py-3.5 text-mob-dim text-xs">{{ $happening->created_at->format('M j, Y') }}</td>
                            <td class="px-5 py-3.5 text-right">
                                <a href="{{ route('admin.happenings.show', $happening) }}" class="text-mob-cyan hover:text-white text-xs font-medium transition-colors">
                                    View
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="px-5 py-12 text-center">
                                <p class="text-mob-dim text-sm">No happenings found.</p>
                                @if(request()->hasAny(['search', 'status', 'category', 'type', 'ticketed']))
                                    <a href="{{ route('admin.happenings.index') }}" class="text-mob-cyan text-sm hover:underline mt-1 inline-block">Clear filters</a>
                                @endif
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($happenings->hasPages())
            <div class="px-5 py-4 border-t border-mob-border">
                {{ $happenings->links() }}
            </div>
        @endif
    </div>
@endsection
