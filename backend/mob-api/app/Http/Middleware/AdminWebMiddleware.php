<?php

namespace App\Http\Middleware;

use App\Enums\UserRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminWebMiddleware
{
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        if (!auth()->guard('web')->check()) {
            return redirect()->route('admin.login');
        }

        $user = auth()->guard('web')->user();

        if (!empty($roles)) {
            $allowed = array_map(fn($r) => UserRole::tryFrom($r), $roles);
            if (!in_array($user->role, $allowed, true)) {
                abort(403, 'Unauthorized');
            }
        } else {

            if (!in_array($user->role, [UserRole::ADMIN, UserRole::MODERATOR], true)) {
                abort(403, 'Unauthorized');
            }
        }

        return $next($request);
    }
}
