<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{




    public function run(): void
    {
        $this->call([
            TestUserSeeder::class,
            TestHappeningSeeder::class,
        ]);

        if (app()->environment('production')) {
            $this->command->info('Skipping DemoDataSeeder in production.');
        } else {
            $this->call(DemoDataSeeder::class);
        }
    }
}
