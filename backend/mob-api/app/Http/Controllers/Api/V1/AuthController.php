<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\HappeningStatus;
use App\Enums\TicketStatus;
use App\Enums\UserRole;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Fcm\RegisterTokenRequest;
use App\Http\Resources\AuthResource;
use App\Http\Resources\UserResource;
use App\Http\Requests\Auth\VerifyEmailRequest;
use App\Http\Requests\Auth\VerifyPhoneRequest;
use App\Models\FcmToken;
use App\Models\User;
use App\Services\EmailVerificationService;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class AuthController extends BaseController
{
    public function register(RegisterRequest $request, EmailVerificationService $emailVerificationService): JsonResponse
    {
        $validated = $request->validated();

        $phone = $validated['phone'];
        if (str_starts_with($phone, '0')) {
            $phone = '+234' . substr($phone, 1);
        }

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $phone,
            'password' => $validated['password'],
            'role' => UserRole::USER,
        ]);


        $verificationToken = $emailVerificationService->generateToken($user);
        Log::info("Email verification token for {$user->email}: {$verificationToken}");

        $token = $user->createToken('auth_token')->plainTextToken;

        return $this->successResponse(
            new AuthResource($user, $token),
            'Registration successful',
            201
        );
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = User::where('email', $validated['email'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            return $this->errorResponse('Invalid credentials', null, 401);
        }

        if ($user->is_guest) {
            return $this->errorResponse('Guest accounts cannot login. Please register.', null, 403);
        }

        $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return $this->successResponse(
            new AuthResource($user, $token),
            'Login successful'
        );
    }

    public function guest(): JsonResponse
    {
        $user = User::create([
            'name' => 'Guest User',
            'email' => 'guest_' . Str::uuid() . '@mob.guest',
            'password' => Hash::make(Str::random(32)),
            'role' => UserRole::GUEST,
            'is_guest' => true,
        ]);

        $token = $user->createToken('guest_token', ['read-only'])->plainTextToken;

        return $this->successResponse(
            new AuthResource($user, $token),
            'Guest session created',
            201
        );
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return $this->successResponse(null, 'Logged out successfully');
    }

    public function user(Request $request): JsonResponse
    {
        $user = $request->user()->load('hostProfile');

        return $this->successResponse(
            new UserResource($user),
            'User retrieved successfully'
        );
    }

    public function sendPhoneOtp(Request $request, OtpService $otpService): JsonResponse
    {
        $request->validate([
            'phone' => ['required', 'string'],
        ]);

        $phone = $request->input('phone');
        if (str_starts_with($phone, '0')) {
            $phone = '+234' . substr($phone, 1);
        }

        $user = $request->user();

        if ($user->phone !== $phone) {
            return $this->errorResponse('Phone number does not match your account.', null, 403);
        }

        $otp = $otpService->generateOtp($phone);

        if (config('otp.bypass_enabled')) {
            Log::debug("OTP bypass active for {$phone} — use code: {$otp}");

            return $this->successResponse(null, 'OTP sent successfully (dev bypass active)');
        }


        Log::info("OTP for {$phone}: {$otp}");

        return $this->successResponse(null, 'OTP sent to your phone number');
    }

    public function verifyPhone(VerifyPhoneRequest $request, OtpService $otpService): JsonResponse
    {
        $validated = $request->validated();

        $phone = $validated['phone'];
        if (str_starts_with($phone, '0')) {
            $phone = '+234' . substr($phone, 1);
        }

        if (! $otpService->verifyOtp($phone, $validated['otp'])) {
            return $this->errorResponse('Invalid or expired OTP', null, 422);
        }

        $user = $request->user();
        $user->update(['phone_verified_at' => now()]);

        return $this->successResponse(
            new UserResource($user->fresh()),
            'Phone verified successfully'
        );
    }

    public function verifyEmail(VerifyEmailRequest $request, EmailVerificationService $emailVerificationService): JsonResponse
    {
        $user = $request->user();

        if (! $emailVerificationService->verifyToken($user, $request->validated('token'))) {
            return $this->errorResponse('Invalid or expired verification token', null, 422);
        }

        $user->update(['email_verified_at' => now()]);

        return $this->successResponse(
            new UserResource($user->fresh()),
            'Email verified successfully'
        );
    }

    public function registerFcmToken(RegisterTokenRequest $request): JsonResponse
    {
        $user = $request->user();
        $token = $request->validated('token');
        $deviceType = $request->validated('device_type');

        $existing = FcmToken::where('token', $token)->first();

        if ($existing) {
            $existing->update([
                'user_id' => $user->id,
                'device_type' => $deviceType ?? $existing->device_type,
                'is_active' => true,
            ]);
        } else {
            FcmToken::create([
                'user_id' => $user->id,
                'token' => $token,
                'device_type' => $deviceType,
                'is_active' => true,
            ]);
        }

        return $this->successResponse(null, 'FCM token registered');
    }

    public function removeFcmToken(Request $request): JsonResponse
    {
        $request->validate([
            'token' => ['required', 'string'],
        ]);

        $fcmToken = FcmToken::where('token', $request->input('token'))
            ->where('user_id', $request->user()->id)
            ->first();

        if ($fcmToken) {
            $fcmToken->update(['is_active' => false]);
        }

        return $this->successResponse(null, 'FCM token removed');
    }




    public function deleteAccount(Request $request): JsonResponse
    {
        $user = $request->user();


        $activeTickets = $user->tickets()
            ->whereIn('status', [TicketStatus::PAID, TicketStatus::PENDING])
            ->whereHas('happening', fn ($q) => $q->where('status', HappeningStatus::ACTIVE))
            ->count();

        if ($activeTickets > 0) {
            return $this->errorResponse(
                'You have active tickets. Wait for events to complete or request refunds first.',
                null,
                422
            );
        }


        $activeHosted = $user->happenings()
            ->where('status', HappeningStatus::ACTIVE)
            ->where('is_ticketed', true)
            ->where('tickets_sold', '>', 0)
            ->count();

        if ($activeHosted > 0) {
            return $this->errorResponse(
                'You have active events with sold tickets. Complete or cancel them first.',
                null,
                422
            );
        }


        $user->happenings()
            ->where('status', HappeningStatus::ACTIVE)
            ->where(fn ($q) => $q->where('is_ticketed', false)->orWhere('tickets_sold', 0))
            ->update(['status' => HappeningStatus::EXPIRED]);


        $user->fcmTokens()->update(['is_active' => false]);


        $user->tokens()->delete();


        $user->delete();

        return $this->successResponse(null, 'Your account has been deleted successfully.');
    }
}
