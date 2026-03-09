<?php

namespace App\Http\Controllers\Admin;

use App\Enums\EscrowAction;
use App\Enums\EscrowStatus;
use App\Enums\TicketStatus;
use App\Http\Controllers\Controller;
use App\Models\Escrow;
use App\Models\EscrowEventLog;
use Illuminate\Http\Request;

class EscrowController extends Controller
{
    public function index(Request $request)
    {
        $query = Escrow::with(['happening', 'host']);


        $status = $request->input('status', 'awaiting_completion');

        if ($status !== 'all') {
            $query->where('status', $status);
        }


        if ($status === 'awaiting_completion') {
            $query->oldest('host_completed_at');
        } else {
            $query->latest();
        }

        $escrows = $query->paginate(20)->withQueryString();

        $counts = [
            'awaiting_completion' => Escrow::where('status', EscrowStatus::AWAITING_COMPLETION)->count(),
            'collecting' => Escrow::where('status', EscrowStatus::COLLECTING)->count(),
            'held' => Escrow::where('status', EscrowStatus::HELD)->count(),
            'released' => Escrow::where('status', EscrowStatus::RELEASED)->count(),
            'refunding' => Escrow::where('status', EscrowStatus::REFUNDING)->count(),
            'refunded' => Escrow::where('status', EscrowStatus::REFUNDED)->count(),
            'total' => Escrow::count(),
        ];


        $financials = [
            'total_held' => Escrow::whereIn('status', [
                EscrowStatus::COLLECTING,
                EscrowStatus::HELD,
                EscrowStatus::AWAITING_COMPLETION,
            ])->sum('total_amount'),
            'awaiting_release' => Escrow::where('status', EscrowStatus::AWAITING_COMPLETION)->sum('host_payout_amount'),
            'total_released' => Escrow::where('status', EscrowStatus::RELEASED)->sum('host_payout_amount'),
            'total_fees_earned' => Escrow::where('status', EscrowStatus::RELEASED)->sum('platform_fee'),
        ];

        return view('admin.escrow.index', compact('escrows', 'counts', 'status', 'financials'));
    }

    public function show(Escrow $escrow)
    {
        $escrow->load([
            'happening.user',
            'host',
            'tickets' => fn($q) => $q->with('user')->latest(),
            'escrowEventLogs' => fn($q) => $q->with('performer')->latest(),
            'payout',
        ]);


        $ticketBreakdown = [
            'paid' => $escrow->tickets()->where('status', TicketStatus::PAID)->count(),
            'refunded' => $escrow->tickets()->where('status', TicketStatus::REFUNDED)->count(),
            'refund_processing' => $escrow->tickets()->where('status', TicketStatus::REFUND_PROCESSING)->count(),
            'pending' => $escrow->tickets()->where('status', TicketStatus::PENDING)->count(),
            'checked_in' => $escrow->tickets()->whereNotNull('checked_in_at')->count(),
        ];

        return view('admin.escrow.show', compact('escrow', 'ticketBreakdown'));
    }

    public function approve(Request $request, Escrow $escrow)
    {
        if ($escrow->status !== EscrowStatus::AWAITING_COMPLETION) {
            return back()->with('error', 'Escrow is not awaiting completion.');
        }

        $escrow->update([
            'status' => EscrowStatus::RELEASED,
            'admin_approved_at' => now(),
            'released_at' => now(),
            'admin_notes' => $request->input('admin_notes'),
        ]);

        EscrowEventLog::create([
            'escrow_id' => $escrow->id,
            'action' => EscrowAction::ADMIN_APPROVED,
            'performed_by_user_id' => auth()->id(),
            'performed_by_role' => 'admin',
            'metadata' => ['notes' => $request->input('admin_notes')],
        ]);

        EscrowEventLog::create([
            'escrow_id' => $escrow->id,
            'action' => EscrowAction::FUNDS_RELEASED,
            'performed_by_user_id' => auth()->id(),
            'performed_by_role' => 'admin',
            'metadata' => [
                'host_payout_amount' => $escrow->host_payout_amount,
                'platform_fee' => $escrow->platform_fee,
            ],
        ]);



        return back()->with('success', "Escrow approved. ₦" . number_format($escrow->host_payout_amount, 2) . " payout queued for {$escrow->host->name}.");
    }

    public function reject(Request $request, Escrow $escrow)
    {
        $request->validate(['admin_notes' => 'required|string|max:500']);

        if ($escrow->status !== EscrowStatus::AWAITING_COMPLETION) {
            return back()->with('error', 'Escrow is not awaiting completion.');
        }

        $escrow->update([
            'status' => EscrowStatus::REFUNDING,
            'refund_initiated_at' => now(),
            'admin_notes' => $request->input('admin_notes'),
        ]);

        EscrowEventLog::create([
            'escrow_id' => $escrow->id,
            'action' => EscrowAction::ADMIN_REJECTED,
            'performed_by_user_id' => auth()->id(),
            'performed_by_role' => 'admin',
            'metadata' => ['notes' => $request->input('admin_notes')],
        ]);



        return back()->with('success', "Escrow rejected. Refund process initiated for {$escrow->tickets_count} tickets.");
    }

    public function refund(Request $request, Escrow $escrow)
    {
        $request->validate(['admin_notes' => 'required|string|max:500']);

        if (in_array($escrow->status, [EscrowStatus::REFUNDED, EscrowStatus::REFUNDING], true)) {
            return back()->with('error', 'Escrow is already refunding or refunded.');
        }

        if ($escrow->status === EscrowStatus::RELEASED) {
            return back()->with('error', 'Cannot refund a released escrow. Funds have already been paid out.');
        }

        $escrow->update([
            'status' => EscrowStatus::REFUNDING,
            'refund_initiated_at' => now(),
            'admin_notes' => $request->input('admin_notes'),
        ]);

        EscrowEventLog::create([
            'escrow_id' => $escrow->id,
            'action' => EscrowAction::ADMIN_OVERRIDE,
            'performed_by_user_id' => auth()->id(),
            'performed_by_role' => 'admin',
            'metadata' => [
                'action' => 'force_refund',
                'notes' => $request->input('admin_notes'),
                'tickets_count' => $escrow->tickets_count,
                'total_amount' => $escrow->total_amount,
            ],
        ]);



        return back()->with('success', "Force refund initiated. {$escrow->tickets_count} tickets totaling ₦" . number_format($escrow->total_amount, 2) . " being refunded.");
    }
}
