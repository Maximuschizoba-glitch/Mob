<?php

namespace App\Http\Controllers;

use App\Models\SiteContent;

class PageController extends Controller
{
    public function home()
    {
        $c = SiteContent::whereIn('group', ['landing', 'about', 'footer'])
            ->orderBy('sort_order')
            ->pluck('value', 'key')
            ->toArray();

        return view('pages.home', ['c' => $c]);
    }

    public function privacy()
    {
        $content = SiteContent::getValue('privacy_policy', '<p>Privacy Policy coming soon.</p>');
        $footer = SiteContent::getGroup('footer');

        return view('pages.legal', ['title' => 'Privacy Policy', 'content' => $content, 'footer' => $footer]);
    }

    public function terms()
    {
        $content = SiteContent::getValue('terms_of_service', '<p>Terms of Service coming soon.</p>');
        $footer = SiteContent::getGroup('footer');

        return view('pages.legal', ['title' => 'Terms of Service', 'content' => $content, 'footer' => $footer]);
    }
}
