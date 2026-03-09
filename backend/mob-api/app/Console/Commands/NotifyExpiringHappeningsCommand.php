<?php

namespace App\Console\Commands;

use App\Enums\HappeningStatus;
use App\Events\HappeningExpiringSoon;
use App\Models\Happening;
use Illuminate\Console\Command;

class NotifyExpiringHappeningsCommand extends Command
{
    protected $signature = 'happenings:notify-expiring';

    protected $description = 'Send notifications for happenings expiring within 1 hour';

    public function handle(): int
    {
        $happenings = Happening::where('status', HappeningStatus::ACTIVE)
            ->where('expires_at', '>', now())
            ->where('expires_at', '<=', now()->addHour())
            ->get();

        foreach ($happenings as $happening) {
            event(new HappeningExpiringSoon($happening));
        }

        $this->info("Notified {$happenings->count()} expiring happenings.");

        return Command::SUCCESS;
    }
}
