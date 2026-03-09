<?php

use App\Enums\HappeningCategory;
use App\Http\Controllers\Api\V1\Admin\DashboardController;
use App\Http\Controllers\Api\V1\Admin\EscrowAdminController;
use App\Http\Controllers\Api\V1\Admin\ModerationController;
use App\Http\Controllers\Api\V1\Admin\VerificationController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\EscrowController;
use App\Http\Controllers\Api\V1\HappeningController;
use App\Http\Controllers\Api\V1\HostController;
use App\Http\Controllers\Api\V1\ReportController;
use App\Http\Controllers\Api\V1\SnapController;
use App\Http\Controllers\Api\V1\TicketController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\WebhookController;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;


Route::prefix('v1')->middleware('throttle:api')->group(function () {


    Route::get('/health', function () {
        $dbOk = false;
        try {
            DB::connection()->getPdo();
            $dbOk = true;
        } catch (\Throwable) {}

        $cacheOk = false;
        try {
            Cache::put('health_check', true, 10);
            $cacheOk = Cache::get('health_check', false);
        } catch (\Throwable) {}

        return response()->json([
            'success' => true,
            'message' => 'Mob API is running',
            'data' => [
                'version' => '1.0.0',
                'environment' => config('app.env'),
                'timezone' => config('app.timezone'),
                'timestamp' => now()->toIso8601String(),
                'services' => [
                    'database' => $dbOk,
                    'cache' => (bool) $cacheOk,
                    'queue' => config('queue.default'),
                ],
            ],
        ]);
    });


    Route::get('/info', function () {
        return response()->json([
            'success' => true,
            'message' => 'Mob API',
            'data' => [
                'name' => 'Mob API',
                'version' => '1.0.0',
                'description' => 'Real-time city discovery platform API',
                'documentation_url' => null,
                'supported_categories' => array_column(HappeningCategory::cases(), 'value'),
                'supported_payment_gateways' => ['paystack', 'flutterwave'],
                'currency' => 'NGN',
                'platform_commission' => '10%',
                'content_expiry_hours' => config('mob.content_expiry_hours', 24),
                'default_feed_radius_km' => config('mob.default_feed_radius_km', 10),
            ],
        ]);
    });


    Route::prefix('auth')->middleware('throttle:auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/guest', [AuthController::class, 'guest']);
    });


    Route::prefix('happenings')->group(function () {
        Route::get('/', [HappeningController::class, 'index']);
        Route::get('/map', [HappeningController::class, 'map']);
        Route::get('/{uuid}', [HappeningController::class, 'show']);
    });
});


Route::prefix('v1')->middleware(['auth:sanctum', 'not-suspended', 'throttle:api'])->group(function () {


    Route::prefix('auth')->middleware('throttle:auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/user', [AuthController::class, 'user']);
        Route::post('/send-phone-otp', [AuthController::class, 'sendPhoneOtp']);
        Route::post('/verify-phone', [AuthController::class, 'verifyPhone']);
        Route::post('/verify-email', [AuthController::class, 'verifyEmail']);
        Route::post('/fcm-token', [AuthController::class, 'registerFcmToken']);
        Route::delete('/fcm-token', [AuthController::class, 'removeFcmToken']);
    });


    Route::delete('/profile', [AuthController::class, 'deleteAccount'])
        ->middleware('not-guest');


    Route::get('/profile/happenings', [HappeningController::class, 'myHappenings']);
    Route::post('/happenings', [HappeningController::class, 'store'])
        ->middleware(['not-guest', 'verified-phone', 'throttle:posting']);
    Route::put('/happenings/{uuid}', [HappeningController::class, 'update'])
        ->middleware('not-guest');
    Route::post('/happenings/{uuid}/end', [HappeningController::class, 'endEvent'])
        ->middleware('not-guest');
    Route::delete('/happenings/{uuid}', [HappeningController::class, 'destroy'])
        ->middleware('not-guest');


    Route::post('/happenings/{uuid}/snaps', [SnapController::class, 'store'])
        ->middleware(['not-guest', 'throttle:posting']);
    Route::get('/happenings/{uuid}/snaps', [SnapController::class, 'index']);


    Route::post('/happenings/{uuid}/report', [ReportController::class, 'store'])
        ->middleware('not-guest');


    Route::middleware('not-guest')->group(function () {
        Route::post('/tickets/purchase', [TicketController::class, 'purchase']);
        Route::get('/tickets', [TicketController::class, 'index']);
        Route::get('/tickets/{uuid}', [TicketController::class, 'show']);
        Route::post('/tickets/{uuid}/verify', [TicketController::class, 'verify']);


        Route::post('/happenings/{uuid}/tickets/verify', [TicketController::class, 'verifyForCheckIn']);
    });


    Route::get('/escrow/{uuid}', [EscrowController::class, 'show'])
        ->middleware('not-guest');
    Route::get('/happenings/{uuid}/escrow', [EscrowController::class, 'showByHappening'])
        ->middleware('not-guest');
    Route::post('/escrow/{uuid}/complete', [EscrowController::class, 'hostMarkComplete'])
        ->middleware(['not-guest', 'host']);


    Route::post('/host/verify', [HostController::class, 'requestVerification'])
        ->middleware('not-guest');
    Route::get('/host/verification-status', [HostController::class, 'verificationStatus'])
        ->middleware('not-guest');


    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::put('/read-all', [NotificationController::class, 'markAllAsRead']);
        Route::get('/unread-count', [NotificationController::class, 'unreadCount']);
        Route::put('/{uuid}/read', [NotificationController::class, 'markAsRead']);
    });
});


Route::prefix('v1/admin')->middleware(['auth:sanctum', 'not-suspended', 'admin', 'throttle:api'])->group(function () {


    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/activity-log', [DashboardController::class, 'activityLog']);


    Route::get('/verifications', [VerificationController::class, 'index']);
    Route::get('/verifications/{id}', [VerificationController::class, 'show']);
    Route::post('/verifications/{id}/approve', [VerificationController::class, 'approve']);
    Route::post('/verifications/{id}/reject', [VerificationController::class, 'reject']);


    Route::get('/reports', [ModerationController::class, 'reportedHappenings']);
    Route::post('/happenings/{id}/hide', [ModerationController::class, 'hideHappening']);
    Route::post('/happenings/{id}/reinstate', [ModerationController::class, 'reinstateHappening']);
    Route::delete('/happenings/{id}', [ModerationController::class, 'deleteHappening']);


    Route::get('/escrows', [EscrowAdminController::class, 'index']);
    Route::get('/escrows/{id}', [EscrowAdminController::class, 'show']);
    Route::post('/escrows/{id}/approve', [EscrowAdminController::class, 'approve']);
    Route::post('/escrows/{id}/reject', [EscrowAdminController::class, 'reject']);
    Route::post('/escrows/{id}/force-refund', [EscrowAdminController::class, 'forceRefund']);
});


Route::prefix('v1/webhooks')->middleware('throttle:webhooks')->group(function () {
    Route::post('/paystack', [WebhookController::class, 'handlePaystack']);
    Route::post('/flutterwave', [WebhookController::class, 'handleFlutterwave']);
});
