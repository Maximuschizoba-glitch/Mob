<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::query();


        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }


        if ($request->filled('role')) {
            $query->where('role', $request->role);
        }


        if ($request->status === 'suspended') {
            $query->whereNotNull('suspended_at');
        } elseif ($request->status === 'active') {
            $query->whereNull('suspended_at');
        }

        $users = $query->latest()->paginate(25)->withQueryString();

        $stats = [
            'total' => User::count(),
            'users' => User::where('role', UserRole::USER)->count(),
            'hosts' => User::where('role', UserRole::HOST)->count(),
            'admins' => User::whereIn('role', [UserRole::ADMIN, UserRole::MODERATOR])->count(),
            'suspended' => User::whereNotNull('suspended_at')->count(),
        ];

        return view('admin.users.index', compact('users', 'stats'));
    }

    public function show(User $user)
    {
        $user->load([
            'happenings' => fn($q) => $q->latest()->take(10),
            'tickets' => fn($q) => $q->with('happening')->latest()->take(10),
            'hostProfile',
            'reports',
        ]);

        return view('admin.users.show', compact('user'));
    }

    public function suspend(Request $request, User $user)
    {
        $request->validate(['reason' => 'required|string|max:500']);

        if ($user->role === UserRole::ADMIN) {
            return back()->with('error', 'Cannot suspend an admin user.');
        }

        $user->update([
            'suspended_at' => now(),
            'suspension_reason' => $request->reason,
        ]);


        $user->tokens()->delete();

        return back()->with('success', "{$user->name} has been suspended.");
    }

    public function unsuspend(User $user)
    {
        $user->update([
            'suspended_at' => null,
            'suspension_reason' => null,
        ]);

        return back()->with('success', "{$user->name} has been unsuspended.");
    }

    public function destroy(User $user)
    {
        if ($user->role === UserRole::ADMIN) {
            return back()->with('error', 'Cannot delete an admin user.');
        }

        $userName = $user->name;
        $user->delete();

        return redirect()->route('admin.users.index')->with('success', "User {$userName} has been deleted.");
    }
}
