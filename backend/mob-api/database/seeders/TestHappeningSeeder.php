<?php

namespace Database\Seeders;

use App\Enums\ActivityLevel;
use App\Enums\HappeningCategory;
use App\Enums\HappeningStatus;
use App\Enums\HappeningType;
use App\Models\Happening;
use App\Models\Snap;
use App\Models\User;
use Illuminate\Database\Seeder;

class TestHappeningSeeder extends Seeder
{
    public function run(): void
    {
        $host = User::where('email', 'host@mob.test')->firstOrFail();
        $user = User::where('email', 'user@mob.test')->firstOrFail();

        $placeholderImage = 'https://placehold.co/600x400/orange/white?text=Mob+Snap';
        $expiresAt = now()->addHours(24);


        $happening1 = Happening::updateOrCreate(
            ['title' => 'Afrobeats Night at Terra Kulture', 'user_id' => $host->id],
            [
                'description' => 'Live Afrobeats performances, DJs, and good vibes all night. Come through for the best nightlife experience on VI.',
                'category' => HappeningCategory::PARTY_NIGHTLIFE,
                'type' => HappeningType::EVENT,
                'latitude' => 6.4316,
                'longitude' => 3.4294,
                'address' => 'Terra Kulture, Plot 1376 Tiamiyu Savage St, Victoria Island, Lagos',
                'starts_at' => now()->addHours(3),
                'is_ticketed' => true,
                'ticket_price' => 5000.00,
                'ticket_quantity' => 100,
                'tickets_sold' => 0,
                'vibe_score' => 8.50,
                'activity_level' => ActivityLevel::HIGH,
                'status' => HappeningStatus::ACTIVE,
                'expires_at' => $expiresAt,
            ]
        );


        $happening2 = Happening::updateOrCreate(
            ['title' => 'Street Food Festival Yaba', 'user_id' => $host->id],
            [
                'description' => 'Local food vendors serving jollof rice, suya, shawarma, and more. Bring your appetite!',
                'category' => HappeningCategory::FOOD_DRINKS,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.5095,
                'longitude' => 3.3711,
                'radius_meters' => 500,
                'address' => 'Herbert Macaulay Way, Yaba, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 6.00,
                'activity_level' => ActivityLevel::MEDIUM,
                'status' => HappeningStatus::ACTIVE,
                'expires_at' => $expiresAt,
            ]
        );


        Happening::updateOrCreate(
            ['title' => 'Chill Vibes at Lekki Beach', 'user_id' => $user->id],
            [
                'description' => 'Relaxing by the water with drinks and good company. Pull up if you are around Lekki.',
                'category' => HappeningCategory::HANGOUTS_SOCIAL,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.4281,
                'longitude' => 3.4752,
                'radius_meters' => 1000,
                'address' => 'Lekki Beach, Lekki Phase 1, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 4.00,
                'activity_level' => ActivityLevel::LOW,
                'status' => HappeningStatus::ACTIVE,
                'expires_at' => $expiresAt,
            ]
        );


        Happening::updateOrCreate(
            ['title' => 'Live Jazz at Bogobiri', 'user_id' => $host->id],
            [
                'description' => 'An evening of smooth jazz in the heart of Ikoyi. Intimate setting, great cocktails.',
                'category' => HappeningCategory::MUSIC_PERFORMANCE,
                'type' => HappeningType::EVENT,
                'latitude' => 6.4363,
                'longitude' => 3.4208,
                'address' => 'Bogobiri House, 9 Maitama Sule St, Ikoyi, Lagos',
                'starts_at' => now()->addHours(5),
                'is_ticketed' => true,
                'ticket_price' => 10000.00,
                'ticket_quantity' => 50,
                'tickets_sold' => 0,
                'vibe_score' => 7.50,
                'activity_level' => ActivityLevel::MEDIUM,
                'status' => HappeningStatus::ACTIVE,
                'expires_at' => $expiresAt,
            ]
        );


        Happening::updateOrCreate(
            ['title' => 'Board Games Meetup', 'user_id' => $user->id],
            [
                'description' => 'Casual board games session. Scrabble, Monopoly, Chess - whatever you are into. Beginners welcome!',
                'category' => HappeningCategory::GAMES_ACTIVITIES,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.4541,
                'longitude' => 3.3947,
                'radius_meters' => 200,
                'address' => 'National Stadium Area, Surulere, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 3.00,
                'activity_level' => ActivityLevel::LOW,
                'status' => HappeningStatus::ACTIVE,
                'expires_at' => $expiresAt,
            ]
        );


        Happening::updateOrCreate(
            ['title' => 'Art Exhibition at Nike Gallery', 'user_id' => $host->id],
            [
                'description' => 'Showcasing contemporary Nigerian art. Free entry, open to all. Four floors of amazing artwork.',
                'category' => HappeningCategory::ART_CULTURE,
                'type' => HappeningType::EVENT,
                'latitude' => 6.4280,
                'longitude' => 3.4750,
                'address' => 'Nike Art Gallery, Lekki-Epe Expressway, Lekki, Lagos',
                'starts_at' => now()->addHours(2),
                'is_ticketed' => false,
                'vibe_score' => 5.50,
                'activity_level' => ActivityLevel::MEDIUM,
                'status' => HappeningStatus::ACTIVE,
                'expires_at' => $expiresAt,
            ]
        );


        Happening::updateOrCreate(
            ['title' => 'Co-working Session at CcHub', 'user_id' => $user->id],
            [
                'description' => 'Productive work session with fast WiFi and good coffee. Developers, designers, writers welcome.',
                'category' => HappeningCategory::STUDY_WORK,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.5158,
                'longitude' => 3.3905,
                'radius_meters' => 100,
                'address' => 'CcHub, 294 Herbert Macaulay Way, Yaba, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 2.00,
                'activity_level' => ActivityLevel::LOW,
                'status' => HappeningStatus::ACTIVE,
                'expires_at' => $expiresAt,
            ]
        );


        $happening8 = Happening::updateOrCreate(
            ['title' => 'Pop-Up Thrift Market Ikeja', 'user_id' => $host->id],
            [
                'description' => 'Vintage and thrift finds at crazy prices. Clothes, shoes, accessories. First come, first served!',
                'category' => HappeningCategory::POPUPS_STREET,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.5944,
                'longitude' => 3.3426,
                'radius_meters' => 300,
                'address' => 'Allen Avenue, Ikeja, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 9.00,
                'activity_level' => ActivityLevel::HIGH,
                'status' => HappeningStatus::ACTIVE,
                'expires_at' => $expiresAt,
            ]
        );


        foreach (range(1, 3) as $i) {
            Snap::updateOrCreate(
                ['media_url' => "{$placeholderImage}&text=Afrobeats+Snap+{$i}"],
                [
                    'happening_id' => $happening1->id,
                    'user_id' => $host->id,
                    'media_type' => 'image',
                    'expires_at' => $expiresAt,
                ]
            );
        }


        foreach (range(1, 2) as $i) {
            Snap::updateOrCreate(
                ['media_url' => "{$placeholderImage}&text=Food+Snap+{$i}"],
                [
                    'happening_id' => $happening2->id,
                    'user_id' => $user->id,
                    'media_type' => 'image',
                    'expires_at' => $expiresAt,
                ]
            );
        }


        foreach (range(1, 3) as $i) {
            Snap::updateOrCreate(
                ['media_url' => "{$placeholderImage}&text=Thrift+Snap+{$i}"],
                [
                    'happening_id' => $happening8->id,
                    'user_id' => $host->id,
                    'media_type' => 'image',
                    'expires_at' => $expiresAt,
                ]
            );
        }
    }
}
