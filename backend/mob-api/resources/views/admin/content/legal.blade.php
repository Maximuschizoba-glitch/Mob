@extends('admin.layouts.app')

@section('title', 'Legal Pages')
@section('page-title', 'Legal Pages')
@section('page-subtitle', 'Privacy Policy & Terms of Service')

@section('content')
    <form method="POST" action="{{ route('admin.content.update') }}">
        @csrf
        @method('PUT')

        @foreach($contents as $content)
            <div class="bg-mob-card rounded-xl border border-mob-border p-6 mb-6">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="text-white font-semibold text-lg">{{ $content->label }}</h3>
                    <a href="{{ $content->key === 'privacy_policy' ? url('/privacy') : url('/terms') }}"
                       target="_blank"
                       class="text-mob-cyan text-sm hover:underline flex items-center gap-1">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
                        Preview
                    </a>
                </div>

                <input type="hidden" name="contents[{{ $loop->index }}][key]" value="{{ $content->key }}">
                <textarea name="contents[{{ $loop->index }}][value]"
                          class="richtext-editor"
                          id="rich_{{ $content->key }}"
                          rows="20">{!! $content->value !!}</textarea>
            </div>
        @endforeach

        <div class="flex justify-end sticky bottom-0 bg-mob-bg py-4 border-t border-mob-border -mx-6 px-6">
            <button type="submit" class="bg-mob-cyan text-mob-bg font-semibold px-8 py-2.5 rounded-lg hover:bg-mob-cyan/90 transition-colors text-sm">
                Save Changes
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
        height: 500,
        menubar: true,
        branding: false,
        plugins: 'lists link code table wordcount',
        toolbar: 'undo redo | blocks | bold italic underline strikethrough | bullist numlist | link table | code',
        content_style: 'body { font-family: -apple-system, sans-serif; font-size: 14px; color: #e5e7eb; background: #1f2937; } h2 { font-size: 1.5em; font-weight: bold; margin-top: 1em; } h3 { font-size: 1.25em; font-weight: bold; margin-top: 0.8em; }',
        setup: function(editor) {
            editor.on('change', function() { editor.save(); });
        }
    });
</script>
@endpush
