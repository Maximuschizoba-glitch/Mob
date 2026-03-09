<?php

namespace App\Console\Commands;

use App\Services\ExpirationService;
use Illuminate\Console\Command;

class ExpireContentCommand extends Command
{
    protected $signature = 'content:expire';

    protected $description = 'Expire happenings and snaps that have passed their 24-hour window';

    public function handle(ExpirationService $expirationService): int
    {
        $happeningsCount = $expirationService->expireHappenings();
        $snapsCount = $expirationService->expireSnaps();

        $this->info("Expired {$happeningsCount} happenings and {$snapsCount} snaps");

        return Command::SUCCESS;
    }
}
