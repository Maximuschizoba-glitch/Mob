<?php

namespace App\Console\Commands;

use App\Enums\EscrowStatus;
use App\Models\Escrow;
use App\Services\RefundService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class CheckRefundsCommand extends Command
{
    protected $signature = 'escrows:check-refunds';

    protected $description = 'Check for overdue refunds and retry failed ones. Ensures all refunds complete within 48 hours.';

    public function __construct(
        private readonly RefundService $refundService,
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        $escrows = Escrow::where('status', EscrowStatus::REFUNDING)->get();

        $overdueCount = 0;

        foreach ($escrows as $escrow) {
            $isOverdue = $escrow->refund_initiated_at
                && $escrow->refund_initiated_at->diffInHours(now()) > 48;

            if ($isOverdue) {
                $overdueCount++;
                $hoursAgo = $escrow->refund_initiated_at->diffInHours(now());

                Log::warning("Escrow {$escrow->uuid} refund overdue — initiated {$hoursAgo} hours ago");
                $this->warn("Escrow {$escrow->uuid} refund overdue — initiated {$hoursAgo} hours ago");
            }

            $result = $this->refundService->retryFailedRefunds($escrow);

            $this->line("Escrow {$escrow->uuid}: {$result['succeeded']}/{$result['total']} refunds succeeded, {$result['failed']} failed");
        }

        $this->info("Checked {$escrows->count()} escrows. {$overdueCount} have overdue refunds.");

        return Command::SUCCESS;
    }
}
