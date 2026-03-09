<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureNotSuspended
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user && $user->suspended_at) {
            return response()->json([
                'success' => false,
                'message' => 'Your account has been suspended.',
                'errors' => [
                    'reason' => $user->suspension_reason ?? 'No reason provided.',
                ],
            ], 403);
        }

        return $next($request);
    }
}
