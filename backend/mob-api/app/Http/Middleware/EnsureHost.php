<?php

namespace App\Http\Middleware;

use App\Enums\UserRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureHost
{
    public function handle(Request $request, Closure $next): Response
    {
        $role = $request->user()?->role;

        if ($role !== UserRole::HOST && $role !== UserRole::ADMIN) {
            return response()->json([
                'success' => false,
                'message' => 'Host access required.',
            ], 403);
        }

        return $next($request);
    }
}
