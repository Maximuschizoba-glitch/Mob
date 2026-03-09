<?php

namespace Database\Seeders;

use App\Enums\HostType;
use App\Enums\UserRole;
use App\Enums\VerificationStatus;
use App\Models\HostProfile;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class TestUserSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@mob.test'],
            [
                'name' => 'Admin User',
                'phone' => '+2348012345678',
                'password' => Hash::make('password'),
                'role' => UserRole::ADMIN,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );

        User::updateOrCreate(
            ['email' => 'user@mob.test'],
            [
                'name' => 'Test User',
                'phone' => '+2348087654321',
                'password' => Hash::make('password'),
                'role' => UserRole::USER,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );

        $host = User::updateOrCreate(
            ['email' => 'host@mob.test'],
            [
                'name' => 'Test Host',
                'phone' => '+2348055555555',
                'password' => Hash::make('password'),
                'role' => UserRole::HOST,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );

        HostProfile::updateOrCreate(
            ['user_id' => $host->id],
            [
                'host_type' => HostType::COMMUNITY,
                'business_name' => 'Test Venue',
                'verification_status' => VerificationStatus::APPROVED,
                'verified_at' => now(),
            ]
        );
    }
}
