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

    public function csaePolicy()
    {
        $content = '
            <p>Mob has a <strong>zero-tolerance policy</strong> toward child sexual abuse and exploitation (CSAE) in any form. This page outlines our standards, enforcement practices, and how to report violations.</p>

            <h2>Our Standards</h2>
            <p>The following content and behaviour is strictly prohibited on Mob:</p>
            <ul>
                <li>Any content that sexually exploits, abuses, or endangers minors</li>
                <li>Child sexual abuse material (CSAM) in any format — images, video, text, or links</li>
                <li>Grooming, solicitation, or any attempt to exploit minors through the platform</li>
                <li>Events or spaces designed to facilitate contact with minors for exploitative purposes</li>
                <li>Sharing, distributing, or promoting any CSAE-related content</li>
            </ul>

            <h2>Enforcement</h2>
            <p>Violations of this policy result in <strong>immediate and permanent account termination</strong>. We do not issue warnings for CSAE violations. Where required by law, we report confirmed violations to the relevant national authorities and to the National Center for Missing &amp; Exploited Children (NCMEC) via CyberTipline.</p>

            <h2>Reporting</h2>
            <p>If you encounter any content or behaviour that violates this policy, report it immediately:</p>
            <p><a href="mailto:safety@mobuniversal.tech">safety@mobuniversal.tech</a></p>
            <p>You can also report child sexual exploitation material directly to NCMEC: <a href="https://www.missingkids.org/gethelpnow/cybertipline" target="_blank" rel="noopener">CyberTipline &rarr;</a></p>

            <h2>Detection &amp; Prevention</h2>
            <p>We take proactive steps to prevent CSAE on our platform, including:</p>
            <ul>
                <li>Review of flagged content and accounts by our trust &amp; safety team</li>
                <li>Automated detection tools to identify potentially harmful content</li>
                <li>Age-appropriate access controls for event creation and discovery</li>
                <li>Regular review of platform policies to meet or exceed industry standards</li>
            </ul>

            <h2>Legal Compliance</h2>
            <p>Mob complies with all applicable laws regarding child protection, including the U.S. PROTECT Our Children Act and equivalent legislation in all jurisdictions where our app operates.</p>

            <h2>Contact</h2>
            <p>For questions about this policy or to report a concern, contact our safety team: <a href="mailto:safety@mobuniversal.tech">safety@mobuniversal.tech</a></p>

            <p style="color:#6B7280; font-size:0.85rem; margin-top:2rem;">Last updated: April 2026</p>
        ';

        $footer = [];

        try {
            $footer = SiteContent::getGroup('footer');
        } catch (\Exception $e) {
            // graceful fallback if DB unavailable
        }

        return view('pages.legal', ['title' => 'Child Safety Policy', 'content' => $content, 'footer' => $footer]);
    }
}
