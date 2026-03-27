<?php

namespace App\Services;

use App\Models\FcmToken;
use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    private string $projectId;

    public function __construct()
    {
        $this->projectId = config('services.firebase.project_id');
    }

    public function sendToUser(User $user, string $title, string $body, ?array $data = null): int
    {
        $tokens = FcmToken::where('user_id', $user->id)
            ->where('is_active', true)
            ->pluck('token');

        if ($tokens->isEmpty()) {
            return 0;
        }

        $successCount = 0;

        foreach ($tokens as $token) {
            if ($this->sendToToken($token, $title, $body, $data)) {
                $successCount++;
            }
        }

        return $successCount;
    }

    public function sendToToken(string $token, string $title, string $body, ?array $data = null): bool
    {
        try {
            $accessToken = $this->getAccessToken();

            $message = [
                'message' => [
                    'token' => $token,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                ],
            ];

            if ($data !== null) {
                $message['message']['data'] = array_map('strval', $data);
            }

            $response = Http::withToken($accessToken)
                ->post(
                    "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send",
                    $message
                );

            if ($response->successful()) {
                return true;
            }

            $errorCode = $response->json('error.details.0.errorCode')
                ?? $response->json('error.status')
                ?? '';

            if (in_array($errorCode, ['UNREGISTERED', 'INVALID_ARGUMENT', 'NOT_FOUND'])) {
                FcmToken::where('token', $token)->update(['is_active' => false]);
                Log::info("FCM token deactivated (reason: {$errorCode})", ['token' => substr($token, 0, 20) . '...']);
            } else {
                Log::warning('FCM send failed', [
                    'status' => $response->status(),
                    'error' => $response->json('error.message'),
                    'token' => substr($token, 0, 20) . '...',
                ]);
            }

            return false;
        } catch (\Exception $e) {
            Log::error('FCM send exception', [
                'message' => $e->getMessage(),
                'token' => substr($token, 0, 20) . '...',
            ]);

            return false;
        }
    }

    public function sendToMultipleUsers(array $userIds, string $title, string $body, ?array $data = null): int
    {
        $tokens = FcmToken::whereIn('user_id', $userIds)
            ->where('is_active', true)
            ->pluck('token');

        if ($tokens->isEmpty()) {
            return 0;
        }

        $successCount = 0;

        foreach ($tokens as $token) {
            if ($this->sendToToken($token, $title, $body, $data)) {
                $successCount++;
            }
        }

        return $successCount;
    }

    public function getAccessToken(): string
    {
        return Cache::remember('fcm_access_token', 50 * 60, function () {
            $credentials = $this->loadFirebaseCredentials();

            $now = time();

            $header = $this->base64UrlEncode(json_encode([
                'alg' => 'RS256',
                'typ' => 'JWT',
            ]));

            $claims = $this->base64UrlEncode(json_encode([
                'iss' => $credentials['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'iat' => $now,
                'exp' => $now + 3600,
            ]));

            $signatureInput = "{$header}.{$claims}";
            $privateKey = openssl_pkey_get_private($credentials['private_key']);

            if (! $privateKey) {
                throw new \RuntimeException('Invalid private key in Firebase credentials');
            }

            openssl_sign($signatureInput, $signature, $privateKey, OPENSSL_ALGO_SHA256);
            $jwt = "{$signatureInput}." . $this->base64UrlEncode($signature);

            $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]);

            if (! $response->successful()) {
                throw new \RuntimeException('Failed to obtain FCM access token: ' . $response->body());
            }

            return $response->json('access_token');
        });
    }

    /**
     * Load Firebase credentials from JSON env var (Railway-safe) or file path fallback.
     */
    private function loadFirebaseCredentials(): array
    {
        // Preferred: FIREBASE_CREDENTIALS_JSON env var (base64-encoded JSON)
        $credentialsJson = config('services.firebase.credentials_json');

        if ($credentialsJson) {
            $decoded = base64_decode($credentialsJson, strict: true);
            $credentials = json_decode($decoded !== false ? $decoded : $credentialsJson, true);

            if (is_array($credentials)) {
                return $credentials;
            }
        }

        // Fallback: file path (local dev)
        $credentialsPath = config('services.firebase.credentials_path');

        if ($credentialsPath && file_exists($credentialsPath)) {
            $credentials = json_decode(file_get_contents($credentialsPath), true);

            if (is_array($credentials)) {
                return $credentials;
            }
        }

        throw new \RuntimeException(
            'Firebase credentials not configured. Set FIREBASE_CREDENTIALS_JSON (base64 JSON) or FIREBASE_CREDENTIALS_PATH.'
        );
    }

    private function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
