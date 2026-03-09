<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class SettingsController extends Controller
{
    public function index()
    {
        $admins = User::whereIn('role', [UserRole::ADMIN, UserRole::MODERATOR])
            ->orderByRaw("FIELD(role, 'admin', 'moderator')")
            ->oldest()
            ->get();

        $counts = [
            'admins' => $admins->where('role', UserRole::ADMIN)->count(),
            'moderators' => $admins->where('role', UserRole::MODERATOR)->count(),
            'total' => $admins->count(),
        ];

        return view('admin.settings.index', compact('admins', 'counts'));
    }

    public function createAdmin(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|in:admin,moderator',
        ]);

        $user = User::create([
            'name' => $request->input('name'),
            'email' => $request->input('email'),
            'password' => Hash::make($request->input('password')),
            'role' => UserRole::from($request->input('role')),
        ]);


        $user->email_verified_at = now();
        $user->save();

        $roleName = $request->input('role') === 'admin' ? 'Admin' : 'Moderator';

        return back()->with('success', "{$request->input('name')} added as {$roleName}.");
    }

    public function removeAdmin(User $user)
    {

        if ($user->id === auth()->id()) {
            return back()->with('error', 'You cannot remove yourself.');
        }


        if (!in_array($user->role, [UserRole::ADMIN, UserRole::MODERATOR], true)) {
            return back()->with('error', 'This user is not an admin or moderator.');
        }


        if ($user->role === UserRole::ADMIN) {
            $adminCount = User::where('role', UserRole::ADMIN)->count();
            if ($adminCount <= 1) {
                return back()->with('error', 'Cannot remove the last admin. At least one admin must exist.');
            }
        }

        $name = $user->name;
        $previousRole = ucfirst($user->role->value);

        $user->update(['role' => UserRole::USER]);


        $user->tokens()->delete();

        return back()->with('success', "{$name} removed as {$previousRole}. Their role is now User.");
    }
}
