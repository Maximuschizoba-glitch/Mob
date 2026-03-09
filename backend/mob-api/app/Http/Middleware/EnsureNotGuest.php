<?php

namespace App\Http\Middleware;

use App\Enums\UserRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureNotGuest
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->role === UserRole::GUEST) {
            return response()->json([
                'success' => false,
                'message' => 'This action requires a full account. Please sign up.',
            ], 403);
        }

        return $next($request);
    }
}
