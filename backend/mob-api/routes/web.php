<?php

use App\Http\Controllers\Admin\AuthController as AdminAuthController;
use App\Http\Controllers\Admin\ContentController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\UserController as AdminUserController;
use App\Http\Controllers\Admin\VerificationController;
use App\Http\Controllers\Admin\HappeningController as AdminHappeningController;
use App\Http\Controllers\Admin\EscrowController;
use App\Http\Controllers\Admin\TicketController as AdminTicketController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Admin\SettingsController;
use App\Http\Controllers\PageController;
use Illuminate\Support\Facades\Route;


Route::get('/', [PageController::class, 'home'])->name('home');
Route::get('/privacy', [PageController::class, 'privacy'])->name('privacy');
Route::get('/terms', [PageController::class, 'terms'])->name('terms');
Route::get('/csae-policy', [PageController::class, 'csaePolicy'])->name('csae-policy');


Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('login.submit');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');
});


Route::prefix('admin')->name('admin.')->middleware('admin.web')->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');


    Route::get('/users', [AdminUserController::class, 'index'])->name('users.index');
    Route::get('/users/{user}', [AdminUserController::class, 'show'])->name('users.show');
    Route::post('/users/{user}/suspend', [AdminUserController::class, 'suspend'])->name('users.suspend');
    Route::post('/users/{user}/unsuspend', [AdminUserController::class, 'unsuspend'])->name('users.unsuspend');
    Route::delete('/users/{user}', [AdminUserController::class, 'destroy'])->name('users.destroy')->middleware('admin.web:admin');


    Route::get('/verifications', [VerificationController::class, 'index'])->name('verifications.index');
    Route::get('/verifications/{hostProfile}', [VerificationController::class, 'show'])->name('verifications.show');
    Route::post('/verifications/{hostProfile}/approve', [VerificationController::class, 'approve'])->name('verifications.approve');
    Route::post('/verifications/{hostProfile}/reject', [VerificationController::class, 'reject'])->name('verifications.reject');


    Route::get('/happenings', [AdminHappeningController::class, 'index'])->name('happenings.index');
    Route::get('/happenings/{happening}', [AdminHappeningController::class, 'show'])->name('happenings.show');
    Route::post('/happenings/{happening}/hide', [AdminHappeningController::class, 'hide'])->name('happenings.hide');
    Route::post('/happenings/{happening}/unhide', [AdminHappeningController::class, 'unhide'])->name('happenings.unhide');


    Route::get('/escrow', [EscrowController::class, 'index'])->name('escrow.index')->middleware('admin.web:admin');
    Route::get('/escrow/{escrow}', [EscrowController::class, 'show'])->name('escrow.show')->middleware('admin.web:admin');
    Route::post('/escrow/{escrow}/approve', [EscrowController::class, 'approve'])->name('escrow.approve')->middleware('admin.web:admin');
    Route::post('/escrow/{escrow}/reject', [EscrowController::class, 'reject'])->name('escrow.reject')->middleware('admin.web:admin');
    Route::post('/escrow/{escrow}/refund', [EscrowController::class, 'refund'])->name('escrow.refund')->middleware('admin.web:admin');


    Route::get('/tickets', [AdminTicketController::class, 'index'])->name('tickets.index');
    Route::get('/tickets/{ticket}', [AdminTicketController::class, 'show'])->name('tickets.show');


    Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
    Route::get('/reports/{report}', [ReportController::class, 'show'])->name('reports.show');
    Route::post('/reports/{report}/dismiss', [ReportController::class, 'dismiss'])->name('reports.dismiss');
    Route::post('/reports/{report}/action', [ReportController::class, 'takeAction'])->name('reports.action');


    Route::get('/content/landing', [ContentController::class, 'landing'])->name('content.landing');
    Route::get('/content/legal', [ContentController::class, 'legal'])->name('content.legal');
    Route::put('/content', [ContentController::class, 'update'])->name('content.update');


    Route::get('/settings', [SettingsController::class, 'index'])->name('settings.index')->middleware('admin.web:admin');
    Route::post('/settings/admins', [SettingsController::class, 'createAdmin'])->name('settings.createAdmin')->middleware('admin.web:admin');
    Route::delete('/settings/admins/{user}', [SettingsController::class, 'removeAdmin'])->name('settings.removeAdmin')->middleware('admin.web:admin');
});
