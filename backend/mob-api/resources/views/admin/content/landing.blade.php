@extends('admin.layouts.app')

@section('title', 'Landing Page Content')
@section('page-title', 'Landing Page')
@section('page-subtitle', 'Edit your public website content')

@section('content')
    <form method="POST" action="{{ route('admin.content.update') }}">
        @csrf
        @method('PUT')

        @php $fieldIndex = 0; @endphp

        @foreach($sections as $sectionName => $items)
            @if($items->isNotEmpty())
            <div class="bg-mob-card rounded-xl border border-mob-border p-6 mb-6">
                <h3 class="text-white font-semibold text-lg mb-1">{{ $sectionName }}</h3>
                <p class="text-mob-dim text-xs mb-5">Edit the {{ strtolower($sectionName) }} section of your landing page</p>

                <div class="space-y-5">
                    @foreach($items as $content)
                        <div>
                            <label class="block text-mob-muted text-sm font-medium mb-1.5">
                                {{ $content->label }}
                                @if($content->description)
                                    <span class="text-mob-dim text-xs font-normal ml-1">— {{ $content->description }}</span>
                                @endif
                            </label>

                            <input type="hidden" name="contents[{{ $fieldIndex }}][key]" value="{{ $content->key }}">

                            @if($content->type === 'text' || $content->type === 'url')
                                <input type="text"
                                       name="contents[{{ $fieldIndex }}][value]"
                                       value="{{ $content->value }}"
                                       class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none transition-colors"
                                       placeholder="{{ $content->type === 'url' ? 'https://...' : '' }}">
                            @elseif($content->type === 'image')
                                <div class="space-y-2">
                                    <input type="text"
                                           name="contents[{{ $fieldIndex }}][value]"
                                           value="{{ $content->value }}"
                                           class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none transition-colors"
                                           placeholder="Paste image URL..."
                                           id="img_{{ $content->key }}">
                                    @if($content->value)
                                        <img src="{{ $content->value }}" class="h-20 rounded-lg object-cover" alt="Preview">
                                    @endif
                                </div>
                            @elseif($content->type === 'textarea')
                                <textarea name="contents[{{ $fieldIndex }}][value]"
                                          rows="3"
                                          class="w-full bg-mob-elevated border border-mob-border rounded-lg px-4 py-2.5 text-sm text-white placeholder-mob-dim focus:border-mob-cyan focus:outline-none resize-y transition-colors">{{ $content->value }}</textarea>
                            @elseif($content->type === 'richtext')
                                <textarea name="contents[{{ $fieldIndex }}][value]"
                                          class="richtext-editor"
                                          id="rich_{{ $content->key }}"
                                          rows="8">{!! $content->value !!}</textarea>
                            @endif
                        </div>
                        @php $fieldIndex++; @endphp
                    @endforeach
                </div>
            </div>
            @endif
        @endforeach

        <div class="flex items-center justify-between sticky bottom-0 bg-mob-bg py-4 border-t border-mob-border -mx-6 px-6">
            <a href="{{ url('/') }}" target="_blank" class="text-mob-cyan text-sm hover:underline flex items-center gap-1">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
                Preview site
            </a>
            <button type="submit" class="bg-mob-cyan text-mob-bg font-semibold px-8 py-2.5 rounded-lg hover:bg-mob-cyan/90 transition-colors text-sm">
                Save All Changes
            </button>
        </div>
    </form>
@endsection

@push('scripts')
<script src="https://cdn.tiny.cloud/1/no-api-key/tinymce/6/tinymce.min.js" referrerpolicy="origin"></script>
<script>
    tinymce.init({
        selector: '.richtext-editor',
        skin: 'oxide-dark',
        content_css: 'dark',
        height: 300,
        menubar: false,
        branding: false,
        plugins: 'lists link code',
        toolbar: 'undo redo | bold italic underline | h2 h3 | bullist numlist | link | code',
        content_style: 'body { font-family: -apple-system, sans-serif; font-size: 14px; color: #e5e7eb; background: #1f2937; }',
        setup: function(editor) {
            editor.on('change', function() { editor.save(); });
        }
    });
</script>
@endpush
