<?php

namespace App\Console\Commands;

use App\Enums\EscrowStatus;
use App\Enums\HappeningStatus;
use App\Models\Happening;
use Illuminate\Console\Command;

class FixCompletedHappeningsCommand extends Command
{
    protected $signature = 'happenings:fix-completed';

    protected $description = 'One-time fix: mark happenings as completed when their escrow is beyond HELD state';

    public function handle(): int
    {


        $happenings = Happening::where('status', HappeningStatus::ACTIVE)
            ->whereHas('escrow', function ($query) {
                $query->whereIn('status', [
                    EscrowStatus::AWAITING_COMPLETION,
                    EscrowStatus::RELEASED,
                    EscrowStatus::REFUNDING,
                    EscrowStatus::REFUNDED,
                ]);
            })
            ->get();

        $count = 0;

        foreach ($happenings as $happening) {
            $happening->update([
                'status' => HappeningStatus::COMPLETED,
                'expires_at' => now(),
            ]);

            $this->line("Fixed: {$happening->uuid} — {$happening->title}");
            $count++;
        }

        $this->info("Fixed {$count} happenings.");

        return Command::SUCCESS;
    }
}
