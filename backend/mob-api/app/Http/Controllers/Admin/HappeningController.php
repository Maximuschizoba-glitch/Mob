<?php

namespace App\Http\Controllers\Admin;

use App\Enums\HappeningStatus;
use App\Enums\TicketStatus;
use App\Http\Controllers\Controller;
use App\Models\Happening;
use Illuminate\Http\Request;

class HappeningController extends Controller
{
    public function index(Request $request)
    {
        $query = Happening::with('user');


        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhereHas('user', fn($uq) => $uq->where('name', 'like', "%{$search}%"));
            });
        }


        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }


        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }


        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }


        if ($request->ticketed === 'yes') {
            $query->where('is_ticketed', true);
        } elseif ($request->ticketed === 'no') {
            $query->where('is_ticketed', false);
        }

        $happenings = $query->latest()->paginate(25)->withQueryString();

        $stats = [
            'total' => Happening::count(),
            'active' => Happening::where('status', HappeningStatus::ACTIVE)->count(),
            'completed' => Happening::where('status', HappeningStatus::COMPLETED)->count(),
            'expired' => Happening::where('status', HappeningStatus::EXPIRED)->count(),
            'hidden' => Happening::whereIn('status', [HappeningStatus::HIDDEN, HappeningStatus::REPORTED])->count(),
            'ticketed' => Happening::where('is_ticketed', true)->count(),
        ];

        return view('admin.happenings.index', compact('happenings', 'stats'));
    }

    public function show(Happening $happening)
    {
        $happening->load([
            'user',
            'snaps',
            'tickets' => fn($q) => $q->with('user')->latest()->take(20),
            'escrow',
            'reports' => fn($q) => $q->with('user')->latest(),
            'hiddenByUser',
        ]);

        $ticketStats = null;
        if ($happening->is_ticketed) {
            $ticketStats = [
                'total_sold' => $happening->tickets()->where('status', TicketStatus::PAID)->count(),
                'total_revenue' => $happening->tickets()->where('status', TicketStatus::PAID)->sum('amount'),
                'refunded' => $happening->tickets()->where('status', TicketStatus::REFUNDED)->count(),
                'pending' => $happening->tickets()->where('status', TicketStatus::PENDING)->count(),
            ];
        }

        return view('admin.happenings.show', compact('happening', 'ticketStats'));
    }

    public function hide(Request $request, Happening $happening)
    {
        $request->validate(['reason' => 'required|string|max:500']);

        $happening->update([
            'status' => HappeningStatus::HIDDEN,
            'hidden_reason' => $request->reason,
            'hidden_by' => auth()->id(),
        ]);

        return back()->with('success', "Happening \"{$happening->title}\" has been hidden.");
    }

    public function unhide(Happening $happening)
    {
        $happening->update([
            'status' => HappeningStatus::ACTIVE,
            'hidden_reason' => null,
            'hidden_by' => null,
        ]);

        return back()->with('success', "Happening \"{$happening->title}\" has been restored.");
    }
}
