<?php

namespace App\Http\Controllers\Admin;

use App\Enums\HappeningStatus;
use App\Http\Controllers\Controller;
use App\Models\Report;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $query = Report::with(['user:id,name,email', 'happening:id,uuid,title,status', 'happening.user:id,name']);


        $status = $request->input('status', 'pending');

        if ($status !== 'all') {
            $query->where('status', $status);
        }


        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->whereHas('happening', fn($hq) => $hq->where('title', 'like', "%{$search}%"))
                  ->orWhereHas('user', fn($uq) => $uq->where('name', 'like', "%{$search}%"));
            });
        }


        if ($request->filled('reason')) {
            $query->where('reason', $request->reason);
        }


        if ($status === 'pending') {
            $query->oldest();
        } else {
            $query->latest();
        }

        $reports = $query->paginate(20)->withQueryString();

        $counts = [
            'pending' => Report::where('status', 'pending')->count(),
            'dismissed' => Report::where('status', 'dismissed')->count(),
            'actioned' => Report::where('status', 'actioned')->count(),
            'total' => Report::count(),
        ];


        $flaggedCount = Report::where('status', 'pending')
            ->selectRaw('happening_id, COUNT(*) as report_count')
            ->groupBy('happening_id')
            ->havingRaw('COUNT(*) >= 3')
            ->get()
            ->count();

        return view('admin.reports.index', compact('reports', 'counts', 'status', 'flaggedCount'));
    }

    public function show(Report $report)
    {
        $report->load(['user', 'happening.user', 'reviewer']);


        $relatedReports = Report::where('happening_id', $report->happening_id)
            ->where('id', '!=', $report->id)
            ->with('user:id,name')
            ->latest()
            ->get();

        $totalReportsForHappening = $relatedReports->count() + 1;

        return view('admin.reports.show', compact('report', 'relatedReports', 'totalReportsForHappening'));
    }

    public function dismiss(Request $request, Report $report)
    {
        if (!$report->isPending()) {
            return back()->with('error', 'This report has already been reviewed.');
        }

        $report->update([
            'status' => 'dismissed',
            'reviewed_by' => auth()->id(),
            'reviewed_at' => now(),
            'admin_notes' => $request->input('admin_notes'),
            'action_taken' => 'none',
        ]);

        return redirect()->route('admin.reports.index')
            ->with('success', 'Report dismissed.');
    }

    public function takeAction(Request $request, Report $report)
    {
        $request->validate([
            'action' => 'required|in:hide,warn',
            'admin_notes' => 'nullable|string|max:500',
        ]);

        if (!$report->isPending()) {
            return back()->with('error', 'This report has already been reviewed.');
        }

        $report->update([
            'status' => 'actioned',
            'reviewed_by' => auth()->id(),
            'reviewed_at' => now(),
            'admin_notes' => $request->input('admin_notes'),
            'action_taken' => $request->action,
        ]);

        $message = 'Report resolved.';


        if ($request->action === 'hide' && $report->happening) {
            $report->happening->update([
                'status' => HappeningStatus::HIDDEN,
                'hidden_reason' => 'Removed due to report: ' . ucfirst(str_replace('_', ' ', $report->reason->value)),
                'hidden_by' => auth()->id(),
            ]);
            $message = "Report resolved. \"{$report->happening->title}\" has been hidden.";
        } elseif ($request->action === 'warn') {
            $message = 'Report resolved. Host has been flagged for warning.';
        }

        return redirect()->route('admin.reports.index')->with('success', $message);
    }
}
