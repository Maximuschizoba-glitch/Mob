<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Always run admin seeder (reads from env vars, safe in production)
        $this->call(AdminSeeder::class);

        if (app()->environment('production')) {
            $this->command->info('Production environment — skipping test seeders.');
            return;
        }

        $this->call([
            TestUserSeeder::class,
            TestHappeningSeeder::class,
            DemoDataSeeder::class,
        ]);
    }
}
