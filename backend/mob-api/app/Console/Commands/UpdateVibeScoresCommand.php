<?php

namespace App\Console\Commands;

use App\Services\VibeScoreService;
use Illuminate\Console\Command;

class UpdateVibeScoresCommand extends Command
{
    protected $signature = 'happenings:update-vibes';

    protected $description = 'Recalculate vibe scores for all active happenings';

    public function __construct(
        private readonly VibeScoreService $vibeScoreService,
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        $count = $this->vibeScoreService->recalculateAllActiveVibes();

        $this->info("Updated vibe scores for {$count} active happenings");

        return Command::SUCCESS;
    }
}
