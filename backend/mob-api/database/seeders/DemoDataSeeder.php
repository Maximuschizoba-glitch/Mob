<?php

namespace Database\Seeders;

use App\Enums\ActivityLevel;
use App\Enums\EscrowAction;
use App\Enums\EscrowStatus;
use App\Enums\HappeningCategory;
use App\Enums\HappeningStatus;
use App\Enums\HappeningType;
use App\Enums\HostType;
use App\Enums\PaymentGateway;
use App\Enums\ReportReason;
use App\Enums\TicketStatus;
use App\Enums\UserRole;
use App\Enums\VerificationStatus;
use App\Models\Escrow;
use App\Models\EscrowEventLog;
use App\Models\Happening;
use App\Models\HostProfile;
use App\Models\Report;
use App\Models\Snap;
use App\Models\Ticket;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        $placeholderImage = 'https://placehold.co/600x400/orange/white?text=Mob+Snap';
        $expiresAt = now()->addHours(24);




        $users = [];
        $userDataList = [
            ['name' => 'Chioma Okafor', 'email' => 'chioma@mob.test', 'phone' => '+2348011111111'],
            ['name' => 'Emeka Adeyemi', 'email' => 'emeka@mob.test', 'phone' => '+2348022222222'],
            ['name' => 'Funke Balogun', 'email' => 'funke@mob.test', 'phone' => '+2348033333333'],
            ['name' => 'Tunde Ojo', 'email' => 'tunde@mob.test', 'phone' => '+2348044444444'],
            ['name' => 'Aisha Mohammed', 'email' => 'aisha@mob.test', 'phone' => '+2348066666666'],
        ];

        foreach ($userDataList as $userData) {

            User::withTrashed()
                ->where('phone', $userData['phone'])
                ->where('email', '!=', $userData['email'])
                ->forceDelete();

            $users[] = User::updateOrCreate(
                ['email' => $userData['email']],
                [
                    'name' => $userData['name'],
                    'phone' => $userData['phone'],
                    'password' => Hash::make('password'),
                    'role' => UserRole::USER,
                    'email_verified_at' => now(),
                    'phone_verified_at' => now(),
                ]
            );
        }






        User::withTrashed()
            ->where('phone', '+2348077777777')
            ->where('email', '!=', 'dayo@mob.test')
            ->forceDelete();
        $hostVerified = User::updateOrCreate(
            ['email' => 'dayo@mob.test'],
            [
                'name' => 'Dayo Amadi',
                'phone' => '+2348077777777',
                'password' => Hash::make('password'),
                'role' => UserRole::HOST,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );
        HostProfile::updateOrCreate(
            ['user_id' => $hostVerified->id],
            [
                'host_type' => HostType::VERIFIED,
                'business_name' => 'Amadi Events Lagos',
                'bio' => 'Premium event planning and hosting across Lagos Island.',
                'verification_status' => VerificationStatus::APPROVED,
                'verification_document_type' => 'cac',
                'verification_document_url' => 'https://storage.example.com/docs/cac-amadi.pdf',
                'verified_at' => now()->subDays(10),
            ]
        );


        User::withTrashed()
            ->where('phone', '+2348088888888')
            ->where('email', '!=', 'ngozi@mob.test')
            ->forceDelete();
        $hostPending = User::updateOrCreate(
            ['email' => 'ngozi@mob.test'],
            [
                'name' => 'Ngozi Eze',
                'phone' => '+2348088888888',
                'password' => Hash::make('password'),
                'role' => UserRole::HOST,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );
        HostProfile::updateOrCreate(
            ['user_id' => $hostPending->id],
            [
                'host_type' => HostType::COMMUNITY,
                'business_name' => 'Ngozi Foodie Hub',
                'bio' => 'Bringing the best food experiences to Yaba and beyond.',
                'verification_status' => VerificationStatus::PENDING,
                'verification_document_type' => 'instagram',
                'verification_document_url' => 'https://instagram.com/ngozifoodiehub',
            ]
        );


        User::withTrashed()
            ->where('phone', '+2348099999999')
            ->where('email', '!=', 'kola@mob.test')
            ->forceDelete();
        $hostRejected = User::updateOrCreate(
            ['email' => 'kola@mob.test'],
            [
                'name' => 'Kola Bankole',
                'phone' => '+2348099999999',
                'password' => Hash::make('password'),
                'role' => UserRole::HOST,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );
        HostProfile::updateOrCreate(
            ['user_id' => $hostRejected->id],
            [
                'host_type' => HostType::COMMUNITY,
                'business_name' => 'Kola Vibes',
                'bio' => 'Underground music events in Surulere.',
                'verification_status' => VerificationStatus::REJECTED,
                'verification_document_type' => 'website',
                'verification_document_url' => 'https://kolavibes.com',
                'admin_notes' => 'Website does not appear to be a legitimate business. Please provide CAC or active Instagram page.',
            ]
        );




        $happenings = [];

        $happeningData = [

            [
                'title' => 'Gidi Groove Friday Night',
                'user_id' => $hostVerified->id,
                'description' => 'The biggest Friday night party on Victoria Island. Top DJs, premium drinks, and an unforgettable atmosphere.',
                'category' => HappeningCategory::PARTY_NIGHTLIFE,
                'type' => HappeningType::EVENT,
                'latitude' => 6.4316, 'longitude' => 3.4294,
                'address' => 'Eko Hotel & Suites, Victoria Island, Lagos',
                'starts_at' => now()->addHours(4),
                'is_ticketed' => true,
                'ticket_price' => 7500.00, 'ticket_quantity' => 200, 'tickets_sold' => 2,
                'vibe_score' => 9.50, 'activity_level' => ActivityLevel::HIGH,
            ],

            [
                'title' => 'Lekki Brunch Club',
                'user_id' => $hostPending->id,
                'description' => 'Bottomless mimosas, small chops, and great conversation. Every Saturday at the Palms.',
                'category' => HappeningCategory::FOOD_DRINKS,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.4480, 'longitude' => 3.4723,
                'radius_meters' => 300,
                'address' => 'The Palms Shopping Mall, Lekki Phase 1, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 6.50, 'activity_level' => ActivityLevel::MEDIUM,
            ],

            [
                'title' => 'Ikoyi Book Club Meetup',
                'user_id' => $users[0]->id,
                'description' => 'Monthly book discussion. This month: Purple Hibiscus. Bring your copy and your opinions.',
                'category' => HappeningCategory::HANGOUTS_SOCIAL,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.4500, 'longitude' => 3.4370,
                'radius_meters' => 150,
                'address' => 'Ikoyi Club, Ikoyi, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 1.50, 'activity_level' => ActivityLevel::LOW,
            ],

            [
                'title' => 'Yaba Underground Sessions',
                'user_id' => $hostRejected->id,
                'description' => 'Live performances from up-and-coming artists. Alté vibes, good energy, cheap drinks.',
                'category' => HappeningCategory::MUSIC_PERFORMANCE,
                'type' => HappeningType::EVENT,
                'latitude' => 6.5095, 'longitude' => 3.3711,
                'address' => 'Freedom Park, Yaba, Lagos',
                'starts_at' => now()->addHours(6),
                'is_ticketed' => true,
                'ticket_price' => 3000.00, 'ticket_quantity' => 80, 'tickets_sold' => 0,
                'vibe_score' => 5.00, 'activity_level' => ActivityLevel::MEDIUM,
            ],

            [
                'title' => 'Surulere Football Pickup',
                'user_id' => $users[1]->id,
                'description' => 'Casual football match at the National Stadium. All skill levels welcome. Bring your boots!',
                'category' => HappeningCategory::GAMES_ACTIVITIES,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.4900, 'longitude' => 3.3500,
                'radius_meters' => 500,
                'address' => 'National Stadium, Surulere, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 8.00, 'activity_level' => ActivityLevel::HIGH,
            ],

            [
                'title' => 'Ikeja Art Walk',
                'user_id' => $hostVerified->id,
                'description' => 'Guided walking tour through Ikeja galleries and murals. Discover local artists and their stories.',
                'category' => HappeningCategory::ART_CULTURE,
                'type' => HappeningType::EVENT,
                'latitude' => 6.5944, 'longitude' => 3.3426,
                'address' => 'Computer Village Area, Ikeja, Lagos',
                'starts_at' => now()->addHours(2),
                'is_ticketed' => false,
                'vibe_score' => 4.50, 'activity_level' => ActivityLevel::MEDIUM,
            ],

            [
                'title' => 'Ajah Freelancer Co-work',
                'user_id' => $users[2]->id,
                'description' => 'Remote workers and freelancers linking up at a cafe in Ajah. Strong WiFi, good coffee.',
                'category' => HappeningCategory::STUDY_WORK,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.4680, 'longitude' => 3.5700,
                'radius_meters' => 100,
                'address' => 'Abraham Adesanya, Ajah, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 0.50, 'activity_level' => ActivityLevel::LOW,
            ],

            [
                'title' => 'Maryland Street Pop-Up',
                'user_id' => $users[3]->id,
                'description' => 'Vendors selling vintage clothes, handmade jewelry, and phone accessories. Prices are mad!',
                'category' => HappeningCategory::POPUPS_STREET,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.5700, 'longitude' => 3.3600,
                'radius_meters' => 400,
                'address' => 'Maryland Mall Area, Maryland, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 7.00, 'activity_level' => ActivityLevel::HIGH,
            ],

            [
                'title' => 'Gbagada Rooftop Party',
                'user_id' => $hostVerified->id,
                'description' => 'Exclusive rooftop party with city views. Limited capacity, premium experience.',
                'category' => HappeningCategory::PARTY_NIGHTLIFE,
                'type' => HappeningType::EVENT,
                'latitude' => 6.5550, 'longitude' => 3.3900,
                'address' => 'Gbagada Phase 2, Lagos',
                'starts_at' => now()->addHours(8),
                'is_ticketed' => true,
                'ticket_price' => 15000.00, 'ticket_quantity' => 60, 'tickets_sold' => 0,
                'vibe_score' => 6.00, 'activity_level' => ActivityLevel::MEDIUM,
            ],

            [
                'title' => 'Oshodi Mama Put Crawl',
                'user_id' => $users[4]->id,
                'description' => 'Eating our way through the best mama put spots in Oshodi. Amala, eba, pounded yam — everything.',
                'category' => HappeningCategory::FOOD_DRINKS,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.5200, 'longitude' => 3.3450,
                'radius_meters' => 600,
                'address' => 'Oshodi Market Area, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 2.50, 'activity_level' => ActivityLevel::LOW,
            ],

            [
                'title' => 'VI Networking Mixer',
                'user_id' => $hostVerified->id,
                'description' => 'Connect with Lagos professionals over cocktails. Tech, finance, creative industries all represented.',
                'category' => HappeningCategory::HANGOUTS_SOCIAL,
                'type' => HappeningType::EVENT,
                'latitude' => 6.4316, 'longitude' => 3.4294,
                'address' => 'The Wheatbaker Hotel, Victoria Island, Lagos',
                'starts_at' => now()->addHours(3),
                'is_ticketed' => true,
                'ticket_price' => 5000.00, 'ticket_quantity' => 100, 'tickets_sold' => 0,
                'vibe_score' => 7.50, 'activity_level' => ActivityLevel::HIGH,
            ],

            [
                'title' => 'Lekki Beach Volleyball',
                'user_id' => $users[1]->id,
                'description' => 'Open volleyball session on the beach. Teams formed on the spot. Just show up and play!',
                'category' => HappeningCategory::GAMES_ACTIVITIES,
                'type' => HappeningType::EVENT,
                'latitude' => 6.4480, 'longitude' => 3.4723,
                'address' => 'Elegushi Beach, Lekki, Lagos',
                'starts_at' => now()->addHours(1),
                'is_ticketed' => false,
                'vibe_score' => 5.50, 'activity_level' => ActivityLevel::MEDIUM,
            ],

            [
                'title' => 'Yaba Street Photography Walk',
                'user_id' => $users[0]->id,
                'description' => 'Photographers exploring Yaba streets together. Phones and cameras welcome. All levels.',
                'category' => HappeningCategory::ART_CULTURE,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.5095, 'longitude' => 3.3711,
                'radius_meters' => 800,
                'address' => 'University of Lagos Road, Yaba, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 3.50, 'activity_level' => ActivityLevel::LOW,
            ],

            [
                'title' => 'Ikeja Live Karaoke Night',
                'user_id' => $hostPending->id,
                'description' => 'Sing your heart out! Full band backing, song requests, prizes for best performer.',
                'category' => HappeningCategory::MUSIC_PERFORMANCE,
                'type' => HappeningType::EVENT,
                'latitude' => 6.5944, 'longitude' => 3.3426,
                'address' => 'Oregun Road, Ikeja, Lagos',
                'starts_at' => now()->addHours(5),
                'is_ticketed' => true,
                'ticket_price' => 2000.00, 'ticket_quantity' => 150, 'tickets_sold' => 0,
                'vibe_score' => 10.00, 'activity_level' => ActivityLevel::HIGH,
            ],

            [
                'title' => 'Surulere Study Group',
                'user_id' => $users[3]->id,
                'description' => 'JAMB and WAEC prep sessions. Bring your past questions and textbooks.',
                'category' => HappeningCategory::STUDY_WORK,
                'type' => HappeningType::CASUAL,
                'latitude' => 6.4900, 'longitude' => 3.3500,
                'radius_meters' => 200,
                'address' => 'Surulere Local Government Area, Lagos',
                'is_ticketed' => false,
                'vibe_score' => 0.00, 'activity_level' => ActivityLevel::LOW,
            ],
        ];

        foreach ($happeningData as $data) {
            $happenings[] = Happening::updateOrCreate(
                ['title' => $data['title'], 'user_id' => $data['user_id']],
                array_merge($data, [
                    'status' => HappeningStatus::ACTIVE,
                    'expires_at' => $expiresAt,
                ])
            );
        }




        $snapData = [

            ['happening' => 0, 'user' => 0, 'text' => 'Gidi+Groove+1'],
            ['happening' => 0, 'user' => 1, 'text' => 'Gidi+Groove+2'],
            ['happening' => 0, 'user' => 2, 'text' => 'Gidi+Groove+3'],

            ['happening' => 4, 'user' => 1, 'text' => 'Football+Action+1'],
            ['happening' => 4, 'user' => 3, 'text' => 'Football+Action+2'],

            ['happening' => 7, 'user' => 3, 'text' => 'Pop+Up+Find+1'],
            ['happening' => 7, 'user' => 4, 'text' => 'Pop+Up+Find+2'],

            ['happening' => 1, 'user' => 2, 'text' => 'Brunch+Vibes'],

            ['happening' => 13, 'user' => 0, 'text' => 'Karaoke+Moment'],

            ['happening' => 10, 'user' => 4, 'text' => 'Networking+Lagos'],
        ];

        foreach ($snapData as $sd) {
            Snap::updateOrCreate(
                ['media_url' => "{$placeholderImage}&text={$sd['text']}"],
                [
                    'happening_id' => $happenings[$sd['happening']]->id,
                    'user_id' => $users[$sd['user']]->id,
                    'media_type' => 'image',
                    'expires_at' => $expiresAt,
                ]
            );
        }






        $reportedHappening = $happenings[14];

        Report::updateOrCreate(
            ['happening_id' => $reportedHappening->id, 'user_id' => $users[0]->id],
            [
                'reason' => ReportReason::FAKE,
                'details' => 'This study group does not exist. Nobody was there when I went.',
                'status' => 'pending',
            ]
        );

        Report::updateOrCreate(
            ['happening_id' => $reportedHappening->id, 'user_id' => $users[1]->id],
            [
                'reason' => ReportReason::MISLEADING,
                'details' => 'The location is wrong, this is nowhere near the address listed.',
                'status' => 'pending',
            ]
        );

        Report::updateOrCreate(
            ['happening_id' => $reportedHappening->id, 'user_id' => $users[2]->id],
            [
                'reason' => ReportReason::WRONG_LOCATION,
                'details' => 'Went to the location, it is a closed shop. Completely fake.',
                'status' => 'pending',
            ]
        );




        $ticketedHappening = $happenings[0];
        $commissionRate = config('mob.platform_commission_rate', 0.10);
        $totalAmount = $ticketedHappening->ticket_price * 2;
        $platformFee = round($totalAmount * $commissionRate, 2);

        $escrow = Escrow::updateOrCreate(
            ['happening_id' => $ticketedHappening->id],
            [
                'host_id' => $ticketedHappening->user_id,
                'total_amount' => $totalAmount,
                'platform_fee' => $platformFee,
                'host_payout_amount' => round($totalAmount - $platformFee, 2),
                'tickets_count' => 2,
                'status' => EscrowStatus::COLLECTING,
            ]
        );


        EscrowEventLog::updateOrCreate(
            ['escrow_id' => $escrow->id, 'action' => EscrowAction::CREATED],
            [
                'performed_by_user_id' => null,
                'performed_by_role' => 'system',
                'metadata' => ['happening_uuid' => $ticketedHappening->uuid],
            ]
        );


        $ticket1 = Ticket::updateOrCreate(
            ['payment_reference' => 'MOB-DEMO-001'],
            [
                'happening_id' => $ticketedHappening->id,
                'escrow_id' => $escrow->id,
                'user_id' => $users[0]->id,
                'payment_gateway' => PaymentGateway::PAYSTACK,
                'amount' => $ticketedHappening->ticket_price,
                'currency' => 'NGN',
                'status' => TicketStatus::PAID,
                'escrow_status_snapshot' => 'collecting',
                'paid_at' => now()->subHours(2),
            ]
        );


        $ticket2 = Ticket::updateOrCreate(
            ['payment_reference' => 'MOB-DEMO-002'],
            [
                'happening_id' => $ticketedHappening->id,
                'escrow_id' => $escrow->id,
                'user_id' => $users[1]->id,
                'payment_gateway' => PaymentGateway::FLUTTERWAVE,
                'amount' => $ticketedHappening->ticket_price,
                'currency' => 'NGN',
                'status' => TicketStatus::PAID,
                'escrow_status_snapshot' => 'collecting',
                'paid_at' => now()->subHours(1),
            ]
        );


        foreach ([$ticket1, $ticket2] as $ticket) {
            EscrowEventLog::updateOrCreate(
                ['escrow_id' => $escrow->id, 'action' => EscrowAction::TICKET_ADDED, 'performed_by_user_id' => $ticket->user_id],
                [
                    'performed_by_role' => 'buyer',
                    'metadata' => [
                        'ticket_uuid' => $ticket->uuid,
                        'amount' => $ticket->amount,
                    ],
                ]
            );
        }
    }
}
