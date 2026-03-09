<?php

namespace App\Http\Controllers\Admin;

use App\Enums\TicketStatus;
use App\Http\Controllers\Controller;
use App\Models\Ticket;
use Illuminate\Http\Request;

class TicketController extends Controller
{
    public function index(Request $request)
    {
        $query = Ticket::with(['user:id,name,email', 'happening:id,uuid,title,status', 'escrow:id,uuid,status']);


        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('uuid', 'like', "%{$search}%")
                  ->orWhere('ticket_number', 'like', "%{$search}%")
                  ->orWhere('payment_reference', 'like', "%{$search}%")
                  ->orWhereHas('user', fn($q2) => $q2->where('name', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%"));
            });
        }


        $status = $request->input('status', 'all');
        if ($status !== 'all') {
            $query->where('status', $status);
        }


        if ($request->filled('gateway')) {
            $query->where('payment_gateway', $request->gateway);
        }


        if ($request->input('checked_in') === 'yes') {
            $query->whereNotNull('checked_in_at');
        } elseif ($request->input('checked_in') === 'no') {
            $query->whereNull('checked_in_at');
        }

        $tickets = $query->latest()->paginate(25)->withQueryString();

        $counts = [
            'paid' => Ticket::where('status', TicketStatus::PAID)->count(),
            'pending' => Ticket::where('status', TicketStatus::PENDING)->count(),
            'refund_processing' => Ticket::where('status', TicketStatus::REFUND_PROCESSING)->count(),
            'refunded' => Ticket::where('status', TicketStatus::REFUNDED)->count(),
            'total' => Ticket::count(),
        ];

        $stats = [
            'total_revenue' => Ticket::where('status', TicketStatus::PAID)->sum('amount'),
            'checked_in' => Ticket::whereNotNull('checked_in_at')->count(),
            'refunded_amount' => Ticket::where('status', TicketStatus::REFUNDED)->sum('amount'),
        ];

        return view('admin.tickets.index', compact('tickets', 'counts', 'stats', 'status'));
    }

    public function show(Ticket $ticket)
    {
        $ticket->load(['user', 'happening', 'escrow']);

        return view('admin.tickets.show', compact('ticket'));
    }
}
