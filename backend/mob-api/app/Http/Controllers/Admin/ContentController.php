<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SiteContent;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ContentController extends Controller
{
    public function landing()
    {
        $sections = [
            'Hero' => SiteContent::where('group', 'landing')->whereBetween('sort_order', [1, 9])->orderBy('sort_order')->get(),
            'Features' => SiteContent::where('group', 'landing')->whereBetween('sort_order', [10, 29])->orderBy('sort_order')->get(),
            'How It Works' => SiteContent::where('group', 'landing')->whereBetween('sort_order', [30, 39])->orderBy('sort_order')->get(),
            'Testimonials' => SiteContent::where('group', 'landing')->whereBetween('sort_order', [40, 49])->orderBy('sort_order')->get(),
            'About' => SiteContent::whereIn('group', ['about'])->orderBy('sort_order')->get(),
            'Download CTA' => SiteContent::where('group', 'landing')->whereBetween('sort_order', [60, 69])->orderBy('sort_order')->get(),
            'Footer' => SiteContent::where('group', 'footer')->orderBy('sort_order')->get(),
        ];

        return view('admin.content.landing', compact('sections'));
    }

    public function legal()
    {
        $contents = SiteContent::where('group', 'legal')->orderBy('sort_order')->get();

        return view('admin.content.legal', compact('contents'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'contents' => 'required|array',
            'contents.*.key' => 'required|string',
            'contents.*.value' => 'nullable|string',
        ]);

        foreach ($request->contents as $item) {
            SiteContent::where('key', $item['key'])->update(['value' => $item['value'] ?? '']);
            Cache::forget("site_content_{$item['key']}");
        }


        Cache::forget('site_content_group_landing');
        Cache::forget('site_content_group_about');
        Cache::forget('site_content_group_footer');
        Cache::forget('site_content_group_legal');

        return back()->with('success', 'Content updated successfully.');
    }
}
