<?php

namespace App\Http\Controllers\Admin;

use App\Enums\EscrowStatus;
use App\Enums\HappeningStatus;
use App\Enums\TicketStatus;
use App\Enums\VerificationStatus;
use App\Http\Controllers\Controller;
use App\Models\Escrow;
use App\Models\Happening;
use App\Models\HostProfile;
use App\Models\Report;
use App\Models\Ticket;
use App\Models\User;

class DashboardController extends Controller
{
    public function index()
    {

        $totalUsers = User::where('is_guest', false)->count();
        $newUsersToday = User::where('is_guest', false)->whereDate('created_at', today())->count();
        $newUsersThisWeek = User::where('is_guest', false)->where('created_at', '>=', now()->startOfWeek())->count();

        $totalHappenings = Happening::count();
        $activeHappenings = Happening::where('status', HappeningStatus::ACTIVE)
            ->where(function ($q) {
                $q->whereNull('expires_at')->orWhere('expires_at', '>', now());
            })->count();

        $totalTicketsSold = Ticket::where('status', TicketStatus::PAID)->count();
        $totalRevenue = Ticket::where('status', TicketStatus::PAID)->sum('amount');
        $revenueToday = Ticket::where('status', TicketStatus::PAID)->whereDate('paid_at', today())->sum('amount');


        $verifiedHosts = HostProfile::where('verification_status', VerificationStatus::APPROVED)->count();
        $pendingVerifications = HostProfile::where('verification_status', VerificationStatus::PENDING)->count();
        $pendingEscrow = Escrow::where('status', EscrowStatus::AWAITING_COMPLETION)->count();
        $pendingReports = Report::where('status', 'pending')->count();


        $recentUsers = User::where('is_guest', false)->latest()->take(5)->get(['id', 'name', 'email', 'role', 'created_at']);
        $recentHappenings = Happening::with('user:id,name')->latest()->take(5)->get();
        $recentTickets = Ticket::with(['user:id,name', 'happening:id,title'])
            ->where('status', TicketStatus::PAID)
            ->latest('paid_at')
            ->take(5)
            ->get();
        $pendingReportsList = Report::with(['happening', 'user'])->where('status', 'pending')->latest()->take(5)->get();


        $revenueChart = collect(range(6, 0))->map(function ($daysAgo) {
            $date = now()->subDays($daysAgo);
            return [
                'date' => $date->format('M d'),
                'amount' => (float) Ticket::where('status', TicketStatus::PAID)
                    ->whereDate('paid_at', $date)
                    ->sum('amount'),
            ];
        });

        return view('admin.dashboard', compact(
            'totalUsers', 'newUsersToday', 'newUsersThisWeek',
            'totalHappenings', 'activeHappenings',
            'totalTicketsSold', 'totalRevenue', 'revenueToday',
            'verifiedHosts', 'pendingVerifications', 'pendingEscrow', 'pendingReports',
            'recentUsers', 'recentHappenings', 'recentTickets', 'pendingReportsList',
            'revenueChart'
        ));
    }
}
