<?php

namespace App\Console\Commands;

use App\Enums\EscrowStatus;
use App\Models\Escrow;
use App\Services\EscrowService;
use Illuminate\Console\Command;

class TransitionEscrowsCommand extends Command
{
    protected $signature = 'escrows:transition-held';

    protected $description = 'Transition escrows from COLLECTING to HELD when event start time is reached';

    public function __construct(
        private readonly EscrowService $escrowService,
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        $escrows = Escrow::where('status', EscrowStatus::COLLECTING)
            ->whereHas('happening', function ($query) {
                $query->where('starts_at', '<=', now());
            })
            ->get();

        foreach ($escrows as $escrow) {
            $this->escrowService->transitionStatus(
                $escrow,
                EscrowStatus::HELD,
                null,
                'system',
                ['reason' => 'Event start time reached']
            );
        }

        $this->info("Transitioned {$escrows->count()} escrows to HELD");

        return Command::SUCCESS;
    }
}
