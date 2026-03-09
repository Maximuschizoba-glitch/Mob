<?php

namespace Database\Seeders;

use App\Models\SiteContent;
use Illuminate\Database\Seeder;

class SiteContentSeeder extends Seeder
{
    public function run(): void
    {
        $contents = [

            ['key' => 'hero_title', 'group' => 'landing', 'label' => 'Hero Title', 'type' => 'text', 'value' => 'See What\'s Happening Now', 'description' => 'Main headline on landing page', 'sort_order' => 1],
            ['key' => 'hero_subtitle', 'group' => 'landing', 'label' => 'Hero Subtitle', 'type' => 'textarea', 'value' => 'Discover real-time events, parties, and happenings around you. Live snaps, vibe scores, and instant tickets — all in one app.', 'description' => 'Text below headline', 'sort_order' => 2],
            ['key' => 'hero_image', 'group' => 'landing', 'label' => 'Hero Image URL', 'type' => 'image', 'value' => '', 'description' => 'Phone mockup or hero image (paste URL)', 'sort_order' => 3],
            ['key' => 'appstore_url', 'group' => 'landing', 'label' => 'App Store URL', 'type' => 'url', 'value' => '#', 'description' => 'Apple App Store link', 'sort_order' => 4],
            ['key' => 'playstore_url', 'group' => 'landing', 'label' => 'Play Store URL', 'type' => 'url', 'value' => '#', 'description' => 'Google Play Store link', 'sort_order' => 5],


            ['key' => 'features_title', 'group' => 'landing', 'label' => 'Features Section Title', 'type' => 'text', 'value' => 'Everything You Need to Discover What\'s Happening', 'description' => '', 'sort_order' => 10],
            ['key' => 'feature_1_icon', 'group' => 'landing', 'label' => 'Feature 1 Icon (emoji)', 'type' => 'text', 'value' => "\u{1F525}", 'description' => '', 'sort_order' => 11],
            ['key' => 'feature_1_title', 'group' => 'landing', 'label' => 'Feature 1 Title', 'type' => 'text', 'value' => 'Live Discovery', 'description' => '', 'sort_order' => 12],
            ['key' => 'feature_1_desc', 'group' => 'landing', 'label' => 'Feature 1 Description', 'type' => 'textarea', 'value' => 'See what\'s happening right now on a live map and feed. Real-time updates, crowd levels, and vibe scores from people actually there.', 'description' => '', 'sort_order' => 13],
            ['key' => 'feature_2_icon', 'group' => 'landing', 'label' => 'Feature 2 Icon', 'type' => 'text', 'value' => "\u{1F4F8}", 'description' => '', 'sort_order' => 14],
            ['key' => 'feature_2_title', 'group' => 'landing', 'label' => 'Feature 2 Title', 'type' => 'text', 'value' => 'Live Snaps', 'description' => '', 'sort_order' => 15],
            ['key' => 'feature_2_desc', 'group' => 'landing', 'label' => 'Feature 2 Description', 'type' => 'textarea', 'value' => 'See the real vibe before you go. Users share live photos from events so you know exactly what to expect.', 'description' => '', 'sort_order' => 16],
            ['key' => 'feature_3_icon', 'group' => 'landing', 'label' => 'Feature 3 Icon', 'type' => 'text', 'value' => "\u{1F39F}\u{FE0F}", 'description' => '', 'sort_order' => 17],
            ['key' => 'feature_3_title', 'group' => 'landing', 'label' => 'Feature 3 Title', 'type' => 'text', 'value' => 'Secure Tickets', 'description' => '', 'sort_order' => 18],
            ['key' => 'feature_3_desc', 'group' => 'landing', 'label' => 'Feature 3 Description', 'type' => 'textarea', 'value' => 'Buy tickets with escrow-protected payments. Your money is safe until the event actually happens.', 'description' => '', 'sort_order' => 19],
            ['key' => 'feature_4_icon', 'group' => 'landing', 'label' => 'Feature 4 Icon', 'type' => 'text', 'value' => "\u{1F451}", 'description' => '', 'sort_order' => 20],
            ['key' => 'feature_4_title', 'group' => 'landing', 'label' => 'Feature 4 Title', 'type' => 'text', 'value' => 'Host Events', 'description' => '', 'sort_order' => 21],
            ['key' => 'feature_4_desc', 'group' => 'landing', 'label' => 'Feature 4 Description', 'type' => 'textarea', 'value' => 'Create and manage your own events with built-in ticket sales, QR code check-in, and a real-time event dashboard.', 'description' => '', 'sort_order' => 22],


            ['key' => 'how_title', 'group' => 'landing', 'label' => 'How It Works Title', 'type' => 'text', 'value' => 'How Mob Works', 'description' => '', 'sort_order' => 30],
            ['key' => 'step_1_title', 'group' => 'landing', 'label' => 'Step 1 Title', 'type' => 'text', 'value' => 'Open the App', 'description' => '', 'sort_order' => 31],
            ['key' => 'step_1_desc', 'group' => 'landing', 'label' => 'Step 1 Description', 'type' => 'textarea', 'value' => 'Browse the live feed or explore the map to see what\'s happening around you right now.', 'description' => '', 'sort_order' => 32],
            ['key' => 'step_2_title', 'group' => 'landing', 'label' => 'Step 2 Title', 'type' => 'text', 'value' => 'Discover & Decide', 'description' => '', 'sort_order' => 33],
            ['key' => 'step_2_desc', 'group' => 'landing', 'label' => 'Step 2 Description', 'type' => 'textarea', 'value' => 'Check live snaps, vibe scores, and crowd levels to decide where to go.', 'description' => '', 'sort_order' => 34],
            ['key' => 'step_3_title', 'group' => 'landing', 'label' => 'Step 3 Title', 'type' => 'text', 'value' => 'Get Tickets & Go', 'description' => '', 'sort_order' => 35],
            ['key' => 'step_3_desc', 'group' => 'landing', 'label' => 'Step 3 Description', 'type' => 'textarea', 'value' => 'Grab your ticket securely, show the QR code at the door, and enjoy.', 'description' => '', 'sort_order' => 36],


            ['key' => 'testimonials_title', 'group' => 'landing', 'label' => 'Testimonials Title', 'type' => 'text', 'value' => 'What People Are Saying', 'description' => '', 'sort_order' => 40],
            ['key' => 'testimonial_1_text', 'group' => 'landing', 'label' => 'Testimonial 1 Quote', 'type' => 'textarea', 'value' => 'Mob changed how I discover events in Lagos. No more FOMO — I can see what\'s actually happening before I leave the house.', 'description' => '', 'sort_order' => 41],
            ['key' => 'testimonial_1_name', 'group' => 'landing', 'label' => 'Testimonial 1 Name', 'type' => 'text', 'value' => 'Tunde A.', 'description' => '', 'sort_order' => 42],
            ['key' => 'testimonial_1_role', 'group' => 'landing', 'label' => 'Testimonial 1 Role/Location', 'type' => 'text', 'value' => 'Lagos, Nigeria', 'description' => '', 'sort_order' => 43],
            ['key' => 'testimonial_2_text', 'group' => 'landing', 'label' => 'Testimonial 2 Quote', 'type' => 'textarea', 'value' => 'As an event host, the escrow system gives my attendees confidence. Ticket sales doubled since I started using Mob.', 'description' => '', 'sort_order' => 44],
            ['key' => 'testimonial_2_name', 'group' => 'landing', 'label' => 'Testimonial 2 Name', 'type' => 'text', 'value' => 'Chioma E.', 'description' => '', 'sort_order' => 45],
            ['key' => 'testimonial_2_role', 'group' => 'landing', 'label' => 'Testimonial 2 Role/Location', 'type' => 'text', 'value' => 'Event Host', 'description' => '', 'sort_order' => 46],
            ['key' => 'testimonial_3_text', 'group' => 'landing', 'label' => 'Testimonial 3 Quote', 'type' => 'textarea', 'value' => 'The live snaps feature is genius. I can literally see the vibe before deciding to go. Never been disappointed.', 'description' => '', 'sort_order' => 47],
            ['key' => 'testimonial_3_name', 'group' => 'landing', 'label' => 'Testimonial 3 Name', 'type' => 'text', 'value' => 'Emeka O.', 'description' => '', 'sort_order' => 48],
            ['key' => 'testimonial_3_role', 'group' => 'landing', 'label' => 'Testimonial 3 Role/Location', 'type' => 'text', 'value' => 'Lagos, Nigeria', 'description' => '', 'sort_order' => 49],


            ['key' => 'about_title', 'group' => 'about', 'label' => 'About Title', 'type' => 'text', 'value' => 'About Mob', 'description' => '', 'sort_order' => 50],
            ['key' => 'about_text', 'group' => 'about', 'label' => 'About Description', 'type' => 'richtext', 'value' => '<p>Mob is your live city guide. We connect people with what\'s happening around them in real-time — from parties and concerts to food pop-ups and casual hangouts.</p><p>Built in Lagos, for Lagos. Everything expires in 24 hours because what matters is what\'s happening <strong>now</strong>.</p>', 'description' => 'Rich text about section', 'sort_order' => 51],


            ['key' => 'cta_title', 'group' => 'landing', 'label' => 'CTA Title', 'type' => 'text', 'value' => 'Ready to See What\'s Happening?', 'description' => 'Download section heading', 'sort_order' => 60],
            ['key' => 'cta_subtitle', 'group' => 'landing', 'label' => 'CTA Subtitle', 'type' => 'textarea', 'value' => 'Download Mob and never miss out on the best events around you.', 'description' => '', 'sort_order' => 61],
            ['key' => 'cta_image', 'group' => 'landing', 'label' => 'CTA Phone Mockup URL', 'type' => 'image', 'value' => '', 'description' => 'Phone mockup image URL', 'sort_order' => 62],


            ['key' => 'footer_description', 'group' => 'footer', 'label' => 'Footer Description', 'type' => 'textarea', 'value' => 'Mob is a real-time social discovery platform that connects you with what\'s happening around you — events, parties, food spots, and more. Everything expires in 24 hours.', 'description' => '', 'sort_order' => 70],
            ['key' => 'footer_email', 'group' => 'footer', 'label' => 'Contact Email', 'type' => 'text', 'value' => 'hello@getbuukride.com', 'description' => '', 'sort_order' => 71],
            ['key' => 'footer_instagram', 'group' => 'footer', 'label' => 'Instagram URL', 'type' => 'url', 'value' => '', 'description' => 'Leave empty to hide', 'sort_order' => 72],
            ['key' => 'footer_twitter', 'group' => 'footer', 'label' => 'Twitter/X URL', 'type' => 'url', 'value' => '', 'description' => 'Leave empty to hide', 'sort_order' => 73],
            ['key' => 'footer_tiktok', 'group' => 'footer', 'label' => 'TikTok URL', 'type' => 'url', 'value' => '', 'description' => 'Leave empty to hide', 'sort_order' => 74],
            ['key' => 'company_name', 'group' => 'footer', 'label' => 'Company Name', 'type' => 'text', 'value' => 'Buuk Tech Solutions Ltd', 'description' => 'Shown as "Powered by" in footer', 'sort_order' => 75],


            ['key' => 'privacy_policy', 'group' => 'legal', 'label' => 'Privacy Policy', 'type' => 'richtext', 'value' => '<h2>Privacy Policy</h2><p>Last updated: March 2026</p><p>This privacy policy describes how Mob collects, uses, and shares your personal information when you use our mobile application.</p><h3>Information We Collect</h3><p>We collect information you provide directly, such as your name, email, phone number, and location data when you use the app.</p><h3>How We Use Your Information</h3><p>We use your information to provide and improve our services, process transactions, and communicate with you.</p><h3>Data Security</h3><p>We implement appropriate security measures to protect your personal information.</p><h3>Contact Us</h3><p>If you have questions about this policy, contact us at hello@getbuukride.com.</p>', 'description' => 'Full Privacy Policy', 'sort_order' => 80],
            ['key' => 'terms_of_service', 'group' => 'legal', 'label' => 'Terms of Service', 'type' => 'richtext', 'value' => '<h2>Terms of Service</h2><p>Last updated: March 2026</p><p>Welcome to Mob. By using our app, you agree to these terms.</p><h3>Use of Service</h3><p>You must be at least 18 years old to use Mob. You agree not to misuse our services.</p><h3>Tickets & Payments</h3><p>All ticket purchases are protected by our escrow system. Funds are held until events are completed.</p><h3>Content</h3><p>You are responsible for the content you post. We reserve the right to remove content that violates our guidelines.</p><h3>Contact</h3><p>Questions? Email hello@getbuukride.com.</p>', 'description' => 'Full Terms of Service', 'sort_order' => 81],
        ];

        foreach ($contents as $content) {
            SiteContent::updateOrCreate(['key' => $content['key']], $content);
        }
    }
}
