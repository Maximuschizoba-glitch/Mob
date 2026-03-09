<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureVerifiedPhone
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->phone_verified_at === null) {
            return response()->json([
                'success' => false,
                'message' => 'Phone verification required to perform this action.',
            ], 403);
        }

        return $next($request);
    }
}
