<?php

namespace App\Services;

use App\Enums\PaymentGateway;
use Illuminate\Support\Facades\Http;

class PaymentService
{
    public function initializePayment(float $amount, string $email, PaymentGateway $gateway, string $reference, ?string $callbackUrl = null): array
    {
        return match ($gateway) {
            PaymentGateway::PAYSTACK => $this->initializePaystack($amount, $email, $reference, $callbackUrl),
            PaymentGateway::FLUTTERWAVE => $this->initializeFlutterwave($amount, $email, $reference, $callbackUrl),
        };
    }

    public function verifyPayment(string $reference, PaymentGateway $gateway): array
    {
        return match ($gateway) {
            PaymentGateway::PAYSTACK => $this->verifyPaystack($reference),
            PaymentGateway::FLUTTERWAVE => $this->verifyFlutterwave($reference),
        };
    }

    public function initiateRefund(string $reference, PaymentGateway $gateway, float $amount): array
    {
        return match ($gateway) {
            PaymentGateway::PAYSTACK => $this->refundPaystack($reference, $amount),
            PaymentGateway::FLUTTERWAVE => $this->refundFlutterwave($reference, $amount),
        };
    }





    private function initializePaystack(float $amount, string $email, string $reference, ?string $callbackUrl): array
    {
        $response = Http::withToken(config('services.paystack.secret_key'))
            ->post('https://api.paystack.co/transaction/initialize', [
                'amount' => (int) ($amount * 100),
                'email' => $email,
                'reference' => $reference,
                'callback_url' => $callbackUrl,
            ]);

        if (! $response->successful() || ! $response->json('status')) {
            throw new \RuntimeException('Paystack initialization failed: ' . ($response->json('message') ?? 'Unknown error'));
        }

        $data = $response->json('data');

        return [
            'authorization_url' => $data['authorization_url'],
            'reference' => $data['reference'],
            'access_code' => $data['access_code'],
        ];
    }

    private function verifyPaystack(string $reference): array
    {
        $response = Http::withToken(config('services.paystack.secret_key'))
            ->get("https://api.paystack.co/transaction/verify/{$reference}");

        if (! $response->successful() || ! $response->json('status')) {
            throw new \RuntimeException('Paystack verification failed: ' . ($response->json('message') ?? 'Unknown error'));
        }

        $data = $response->json('data');

        return [
            'status' => $data['status'],
            'amount' => $data['amount'] / 100,
            'reference' => $data['reference'],
            'gateway_response' => $data['gateway_response'],
        ];
    }

    private function refundPaystack(string $reference, float $amount): array
    {
        $verifyResponse = Http::withToken(config('services.paystack.secret_key'))
            ->get("https://api.paystack.co/transaction/verify/{$reference}");

        if (! $verifyResponse->successful() || ! $verifyResponse->json('status')) {
            throw new \RuntimeException('Paystack refund failed: could not verify transaction');
        }

        $transactionId = $verifyResponse->json('data.id');

        $response = Http::withToken(config('services.paystack.secret_key'))
            ->post('https://api.paystack.co/refund', [
                'transaction' => $transactionId,
                'amount' => (int) ($amount * 100),
            ]);

        if (! $response->successful() || ! $response->json('status')) {
            throw new \RuntimeException('Paystack refund failed: ' . ($response->json('message') ?? 'Unknown error'));
        }

        $data = $response->json('data');

        return [
            'status' => $data['status'],
            'refund_reference' => $data['transaction']['reference'] ?? $reference,
        ];
    }





    private function initializeFlutterwave(float $amount, string $email, string $reference, ?string $callbackUrl): array
    {
        $response = Http::withToken(config('services.flutterwave.secret_key'))
            ->post('https://api.flutterwave.com/v3/payments', [
                'tx_ref' => $reference,
                'amount' => $amount,
                'currency' => 'NGN',
                'redirect_url' => $callbackUrl,
                'customer' => [
                    'email' => $email,
                ],
            ]);

        if (! $response->successful() || $response->json('status') !== 'success') {
            throw new \RuntimeException('Flutterwave initialization failed: ' . ($response->json('message') ?? 'Unknown error'));
        }

        return [
            'authorization_url' => $response->json('data.link'),
            'reference' => $reference,
        ];
    }

    private function verifyFlutterwave(string $reference): array
    {
        $response = Http::withToken(config('services.flutterwave.secret_key'))
            ->get('https://api.flutterwave.com/v3/transactions/verify_by_reference', [
                'tx_ref' => $reference,
            ]);

        if (! $response->successful() || $response->json('status') !== 'success') {
            throw new \RuntimeException('Flutterwave verification failed: ' . ($response->json('message') ?? 'Unknown error'));
        }

        $data = $response->json('data');

        return [
            'status' => $data['status'],
            'amount' => (float) $data['amount'],
            'reference' => $data['tx_ref'],
            'gateway_response' => $data['processor_response'] ?? $data['status'],
        ];
    }

    private function refundFlutterwave(string $reference, float $amount): array
    {
        $verifyResponse = Http::withToken(config('services.flutterwave.secret_key'))
            ->get('https://api.flutterwave.com/v3/transactions/verify_by_reference', [
                'tx_ref' => $reference,
            ]);

        if (! $verifyResponse->successful() || $verifyResponse->json('status') !== 'success') {
            throw new \RuntimeException('Flutterwave refund failed: could not verify transaction');
        }

        $transactionId = $verifyResponse->json('data.id');

        $response = Http::withToken(config('services.flutterwave.secret_key'))
            ->post("https://api.flutterwave.com/v3/transactions/{$transactionId}/refund", [
                'amount' => $amount,
            ]);

        if (! $response->successful() || $response->json('status') !== 'success') {
            throw new \RuntimeException('Flutterwave refund failed: ' . ($response->json('message') ?? 'Unknown error'));
        }

        $data = $response->json('data');

        return [
            'status' => $data['status'],
            'refund_reference' => (string) ($data['id'] ?? $reference),
        ];
    }
}
