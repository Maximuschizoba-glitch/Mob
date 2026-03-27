<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\EscrowAction;
use App\Enums\EscrowStatus;
use App\Enums\PaymentGateway;
use App\Enums\TicketStatus;
use App\Models\EscrowEventLog;
use App\Models\Ticket;
use App\Services\EscrowService;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class WebhookController extends BaseController
{
    public function __construct(
        private readonly PaymentService $paymentService,
        private readonly EscrowService $escrowService,
    ) {}

    public function handlePaystack(Request $request): Response
    {
        $signature = $request->header('x-paystack-signature');
        $computed = hash_hmac('sha512', $request->getContent(), config('services.paystack.webhook_secret'));

        if (! $signature || ! hash_equals($computed, $signature)) {
            return response('Unauthorized', 401);
        }

        $event = $request->input('event');

        if ($event === 'charge.success') {
            $reference = $request->input('data.reference');
            $this->handleSuccessfulPayment($reference, PaymentGateway::PAYSTACK);
        }

        if ($event === 'refund.processed') {
            $reference = $request->input('data.transaction.reference');
            $this->handleSuccessfulRefund($reference);
        }

        return response('OK', 200);
    }

    public function handleFlutterwave(Request $request): Response
    {
        $hash = $request->header('verif-hash');
        $secret = config('services.flutterwave.webhook_secret');

        if (! $hash || ! $secret || ! hash_equals($secret, $hash)) {
            return response('Unauthorized', 401);
        }

        $event = $request->input('event');

        if ($event === 'charge.completed') {
            $reference = $request->input('data.tx_ref');

            try {
                $verification = $this->paymentService->verifyPayment($reference, PaymentGateway::FLUTTERWAVE);

                if ($verification['status'] === 'successful') {
                    $this->handleSuccessfulPayment($reference, PaymentGateway::FLUTTERWAVE);
                }
            } catch (\Throwable $e) {
                Log::error('Flutterwave webhook verification failed', [
                    'reference' => $reference,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return response('OK', 200);
    }

    protected function handleSuccessfulPayment(string $reference, PaymentGateway $gateway): void
    {
        $ticket = Ticket::where('payment_reference', $reference)
            ->where('status', TicketStatus::PENDING)
            ->first();

        if (! $ticket) {
            return;
        }

        try {
            $ticketController = app(TicketController::class);
            $ticketController->processConfirmedPayment($ticket);
        } catch (\Throwable $e) {
            Log::error('Webhook: processConfirmedPayment failed', [
                'reference' => $reference,
                'gateway' => $gateway->value,
                'error' => $e->getMessage(),
            ]);
        }
    }

    protected function handleSuccessfulRefund(string $reference): void
    {
        $ticket = Ticket::where('payment_reference', $reference)->first();

        if (! $ticket || $ticket->status === TicketStatus::REFUNDED) {
            return;
        }

        DB::transaction(function () use ($ticket) {
            $ticket->status = TicketStatus::REFUNDED;
            $ticket->refunded_at = now();
            $ticket->save();

            if ($ticket->escrow_id) {
                EscrowEventLog::create([
                    'escrow_id' => $ticket->escrow_id,
                    'action' => EscrowAction::TICKET_REFUNDED,
                    'performed_by_user_id' => null,
                    'performed_by_role' => 'system',
                    'metadata' => [
                        'ticket_uuid' => $ticket->uuid,
                        'amount' => $ticket->amount,
                        'source' => 'webhook',
                    ],
                ]);

                $escrow = $ticket->escrow;
                $allRefunded = $escrow->tickets()
                    ->where('status', '!=', TicketStatus::REFUNDED)
                    ->doesntExist();

                if ($allRefunded) {
                    $escrow->refund_completed_at = now();

                    $this->escrowService->transitionStatus(
                        $escrow,
                        EscrowStatus::REFUNDED,
                        null,
                        'system',
                        ['action' => EscrowAction::REFUND_COMPLETED->value, 'source' => 'webhook']
                    );
                }
            }
        });
    }
}
