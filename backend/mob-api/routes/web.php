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
Route::get('/csae-policy', function () {
    return response('<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Child Safety Policy — Mob</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
body { font-family: "Plus Jakarta Sans", sans-serif; background: #0A0E1A; color: #F9FAFB; }
.gradient-text { background: linear-gradient(135deg, #00F0FF, #A855F7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.prose h2 { font-size: 1.3rem; font-weight: 700; color: #F9FAFB; margin-top: 2rem; margin-bottom: 0.75rem; }
.prose p { color: #9CA3AF; line-height: 1.75; margin-bottom: 1rem; }
.prose ul { color: #9CA3AF; margin-bottom: 1rem; padding-left: 1.5rem; list-style: disc; }
.prose li { margin-bottom: 0.25rem; }
.prose a { color: #00F0FF; }
.prose strong { color: #F9FAFB; }
</style>
</head>
<body class="antialiased">
<nav class="fixed top-0 w-full z-50 bg-black/80 backdrop-blur-xl border-b border-white/10">
  <div class="max-w-4xl mx-auto px-6 py-4 flex items-center justify-between">
    <a href="/" class="gradient-text font-bold text-2xl tracking-widest">MOB</a>
    <a href="/" class="text-sm text-gray-400 hover:text-white">&larr; Back to Home</a>
  </div>
</nav>
<main class="max-w-3xl mx-auto px-6 pt-28 pb-20">
  <p class="text-xs text-gray-500 uppercase tracking-widest mb-2">Safety Policy</p>
  <h1 class="text-4xl font-bold mb-2">Child Safety Standards</h1>
  <p class="text-sm text-gray-500 mb-10">Last updated: April 2026</p>
  <div class="prose">
    <p>Mob has a <strong>zero-tolerance policy</strong> toward child sexual abuse and exploitation (CSAE) in any form. This page outlines our standards, enforcement practices, and how to report violations.</p>
    <h2>Our Standards</h2>
    <p>The following content and behaviour is strictly prohibited on Mob:</p>
    <ul>
      <li>Any content that sexually exploits, abuses, or endangers minors</li>
      <li>Child sexual abuse material (CSAM) in any format — images, video, text, or links</li>
      <li>Grooming, solicitation, or any attempt to exploit minors through the platform</li>
      <li>Events or spaces designed to facilitate contact with minors for exploitative purposes</li>
      <li>Sharing, distributing, or promoting any CSAE-related content</li>
    </ul>
    <h2>Enforcement</h2>
    <p>Violations result in <strong>immediate and permanent account termination</strong>. We do not issue warnings for CSAE violations. Where required by law, we report confirmed violations to national authorities and to NCMEC via CyberTipline.</p>
    <h2>Reporting</h2>
    <p>Report violations immediately: <a href="mailto:safety@mobuniversal.tech">safety@mobuniversal.tech</a></p>
    <p>You can also report directly to NCMEC: <a href="https://www.missingkids.org/gethelpnow/cybertipline" target="_blank">CyberTipline &rarr;</a></p>
    <h2>Detection &amp; Prevention</h2>
    <ul>
      <li>Flagged content review by our trust &amp; safety team</li>
      <li>Automated detection tools for harmful content</li>
      <li>Age-appropriate access controls</li>
      <li>Regular policy reviews to meet industry standards</li>
    </ul>
    <h2>Legal Compliance</h2>
    <p>Mob complies with all applicable child protection laws, including the U.S. PROTECT Our Children Act and equivalent legislation in all jurisdictions where we operate.</p>
    <h2>Contact</h2>
    <p><a href="mailto:safety@mobuniversal.tech">safety@mobuniversal.tech</a></p>
  </div>
</main>
<footer class="border-t border-white/5 py-8 text-center text-sm text-gray-600">
  &copy; 2026 Mob &mdash; mobuniversal.tech
</footer>
</body>
</html>', 200, ['Content-Type' => 'text/html']);
})->name('csae-policy');


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
