<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\HappeningStatus;
use App\Enums\PaymentGateway;
use App\Enums\TicketStatus;
use App\Events\TicketPurchased;
use App\Http\Requests\Ticket\PurchaseTicketRequest;
use App\Http\Resources\TicketResource;
use App\Models\Happening;
use App\Models\Ticket;
use App\Services\EscrowService;
use App\Services\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class TicketController extends BaseController
{
    public function __construct(
        private readonly PaymentService $paymentService,
        private readonly EscrowService $escrowService,
    ) {}

    public function purchase(PurchaseTicketRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $happening = Happening::where('uuid', $validated['happening_uuid'])->first();

        if (! $happening->is_ticketed) {
            return $this->errorResponse('This happening is not ticketed', null, 422);
        }

        if ($happening->status !== HappeningStatus::ACTIVE) {
            $message = match ($happening->status) {
                HappeningStatus::COMPLETED => 'This event has ended. Tickets are no longer available.',
                HappeningStatus::EXPIRED => 'This event has expired. Tickets are no longer available.',
                HappeningStatus::HIDDEN => 'This event is no longer available.',
                default => 'Tickets are not available for this event.',
            };
            return $this->errorResponse($message, null, 422);
        }

        if ($happening->expires_at->isPast()) {
            return $this->errorResponse('This event has expired. Tickets are no longer available.', null, 422);
        }

        $quantity = (int) ($validated['quantity'] ?? 1);
        $remaining = $happening->ticket_quantity - $happening->tickets_sold;

        if ($quantity > $remaining) {
            return $this->errorResponse(
                $remaining > 0
                    ? "Only {$remaining} ticket(s) remaining."
                    : 'No tickets available.',
                null,
                422
            );
        }

        $unitPrice = $happening->ticket_price;
        $totalAmount = $unitPrice * $quantity;

        $reference = 'MOB-' . strtoupper(Str::random(16));
        $gateway = PaymentGateway::from($validated['payment_gateway']);
        $user = $request->user();

        try {
            $result = DB::transaction(function () use ($happening, $user, $reference, $gateway, $validated, $quantity, $totalAmount) {


                $ticket = Ticket::create([
                    'happening_id' => $happening->id,
                    'user_id' => $user->id,
                    'quantity' => $quantity,
                    'amount' => $totalAmount,
                    'currency' => 'NGN',
                    'payment_reference' => $reference,
                    'payment_gateway' => $gateway,
                    'status' => TicketStatus::PENDING,
                ]);


                $payment = $this->paymentService->initializePayment(
                    $totalAmount,
                    $user->email,
                    $gateway,
                    $reference,
                    $validated['callback_url'] ?? null
                );

                $ticket->load(['happening', 'escrow']);

                return [
                    'ticket' => $ticket,
                    'payment_url' => $payment['authorization_url'],
                ];
            });

            return $this->successResponse([
                'ticket' => new TicketResource($result['ticket']),
                'payment_url' => $result['payment_url'],
            ], 'Payment initialized. Complete payment to confirm your ticket.', 201);
        } catch (\Throwable $e) {
            return $this->errorResponse('Payment initialization failed: ' . $e->getMessage(), null, 500);
        }
    }

    public function index(Request $request): JsonResponse
    {
        $tickets = Ticket::where('user_id', $request->user()->id)
            ->where('status', '!=', TicketStatus::PENDING)
            ->with(['happening', 'escrow'])
            ->orderByDesc('created_at')
            ->paginate(20);

        return $this->paginatedResponse($tickets, TicketResource::class, 'Tickets retrieved successfully');
    }

    public function show(string $uuid): JsonResponse
    {
        $ticket = Ticket::where('uuid', $uuid)
            ->where('user_id', auth()->id())
            ->with([
                'happening',
                'escrow',
                'escrow.escrowEventLogs' => function ($query) {
                    $query->orderBy('created_at');
                },
            ])
            ->first();

        if (! $ticket) {
            return $this->errorResponse('Ticket not found', null, 404);
        }

        return $this->successResponse(
            new TicketResource($ticket),
            'Ticket retrieved successfully'
        );
    }




    public function verify(string $uuid): JsonResponse
    {
        $ticket = Ticket::where('uuid', $uuid)
            ->where('user_id', auth()->id())
            ->with(['happening', 'escrow'])
            ->first();

        if (! $ticket) {
            return $this->errorResponse('Ticket not found', null, 404);
        }


        if ($ticket->status === TicketStatus::PAID) {
            $tickets = Ticket::where('payment_reference', $ticket->payment_reference)
                ->where('status', TicketStatus::PAID)
                ->with([
                    'happening',
                    'escrow',
                    'escrow.escrowEventLogs' => fn ($q) => $q->orderBy('created_at'),
                ])
                ->get();

            return $this->successResponse([
                'tickets' => TicketResource::collection($tickets),
            ], 'Payment already confirmed');
        }


        if ($ticket->status !== TicketStatus::PENDING) {
            return $this->errorResponse(
                'Ticket cannot be verified (status: ' . $ticket->status->value . ')',
                null,
                422
            );
        }

        $gateway = $ticket->payment_gateway;

        try {
            $verification = $this->paymentService->verifyPayment(
                $ticket->payment_reference,
                $gateway,
            );


            $isSuccess = in_array($verification['status'], ['success', 'successful'], true);

            if (! $isSuccess) {
                return $this->errorResponse(
                    'Payment not yet confirmed by gateway (status: ' . $verification['status'] . ')',
                    null,
                    402
                );
            }


            $tickets = $this->processConfirmedPayment($ticket);

            return $this->successResponse([
                'tickets' => TicketResource::collection($tickets),
            ], 'Payment verified and tickets confirmed');
        } catch (\Throwable $e) {
            Log::error('Payment verification failed', [
                'ticket_uuid' => $uuid,
                'reference' => $ticket->payment_reference,
                'gateway' => $gateway->value,
                'error' => $e->getMessage(),
            ]);

            return $this->errorResponse(
                'Payment verification failed: ' . $e->getMessage(),
                null,
                500
            );
        }
    }




    public function processConfirmedPayment(Ticket $pendingTicket): \Illuminate\Support\Collection
    {
        return DB::transaction(function () use ($pendingTicket) {

            $ticket = Ticket::where('id', $pendingTicket->id)
                ->lockForUpdate()
                ->first();


            if ($ticket->status === TicketStatus::PAID) {
                return Ticket::where('payment_reference', $ticket->payment_reference)
                    ->where('status', TicketStatus::PAID)
                    ->with(['happening', 'escrow'])
                    ->get();
            }

            $happening = $ticket->happening;
            $quantity = $ticket->quantity;
            $unitPrice = $happening->ticket_price;


            $escrow = $happening->escrow;
            if (! $escrow) {
                $escrow = $this->escrowService->createEscrow($happening);
            }

            $allTickets = collect();


            $ticket->status = TicketStatus::PAID;
            $ticket->paid_at = now();
            $ticket->amount = $unitPrice;
            $ticket->quantity = 1;
            $ticket->ticket_number = $this->generateTicketNumber($happening, 1);
            $ticket->escrow_id = $escrow->id;
            $ticket->escrow_status_snapshot = 'collecting';
            $ticket->save();

            $this->escrowService->addTicketToEscrow($escrow, $ticket);
            $allTickets->push($ticket);


            for ($i = 2; $i <= $quantity; $i++) {
                $newTicket = Ticket::create([
                    'happening_id' => $happening->id,
                    'user_id' => $ticket->user_id,
                    'escrow_id' => $escrow->id,
                    'quantity' => 1,
                    'ticket_number' => $this->generateTicketNumber($happening, $i),
                    'payment_reference' => $ticket->payment_reference,
                    'payment_gateway' => $ticket->payment_gateway,
                    'amount' => $unitPrice,
                    'currency' => $ticket->currency,
                    'status' => TicketStatus::PAID,
                    'escrow_status_snapshot' => 'collecting',
                    'paid_at' => now(),
                ]);

                $this->escrowService->addTicketToEscrow($escrow, $newTicket);
                $allTickets->push($newTicket);
            }


            $happening->increment('tickets_sold', $quantity);


            event(new TicketPurchased($ticket, $happening));


            $allTickets->each(fn ($t) => $t->load(['happening', 'escrow']));

            return $allTickets;
        });
    }




    private function generateTicketNumber(Happening $happening, int $index): string
    {
        $prefix = strtoupper(substr(preg_replace('/[^a-zA-Z]/', '', $happening->title), 0, 3));
        if (strlen($prefix) < 3) {
            $prefix = str_pad($prefix, 3, 'X');
        }
        $count = $happening->tickets_sold + $index;

        return "{$prefix}-" . str_pad($count, 4, '0', STR_PAD_LEFT);
    }




    public function verifyForCheckIn(Request $request, string $happeningUuid): JsonResponse
    {
        $user = $request->user();

        $happening = Happening::where('uuid', $happeningUuid)->first();

        if (! $happening) {
            return $this->errorResponse('Happening not found', null, 404);
        }

        if ($happening->user_id !== $user->id) {
            return $this->errorResponse(
                'Only the host can scan tickets for this event',
                null,
                403
            );
        }

        $request->validate([
            'ticket_uuid' => 'required|string',
        ]);

        $ticketUuid = $request->input('ticket_uuid');

        $ticket = Ticket::where('uuid', $ticketUuid)
            ->with(['user', 'happening'])
            ->first();

        if (! $ticket) {
            return $this->successResponse([
                'status' => 'invalid',
                'message' => 'This QR code is not a valid Mob ticket.',
            ], 'Invalid ticket');
        }

        if ($ticket->happening_id !== $happening->id) {
            return $this->successResponse([
                'status' => 'wrong_event',
                'message' => 'This ticket is for a different event.',
                'ticket_event' => $ticket->happening?->title,
            ], 'Wrong event');
        }

        if ($ticket->status === TicketStatus::PENDING) {
            return $this->successResponse([
                'status' => 'pending',
                'message' => 'This ticket has not been paid yet.',
            ], 'Payment pending');
        }

        if ($ticket->status === TicketStatus::REFUNDED
            || $ticket->status === TicketStatus::REFUND_PROCESSING) {
            return $this->successResponse([
                'status' => 'refunded',
                'message' => 'This ticket has been refunded.',
            ], 'Ticket refunded');
        }

        if ($ticket->checked_in_at !== null) {
            return $this->successResponse([
                'status' => 'already_checked_in',
                'message' => 'This ticket was already checked in.',
                'checked_in_at' => $ticket->checked_in_at->toIso8601String(),
                'attendee_name' => $ticket->user?->name,
            ], 'Already checked in');
        }

        $ticket->checked_in_at = now();
        $ticket->save();

        return $this->successResponse([
            'status' => 'valid',
            'message' => 'Ticket verified! Welcome in.',
            'attendee_name' => $ticket->user?->name,
            'ticket_number' => $ticket->ticket_number,
            'ticket_uuid' => $ticket->uuid,
            'checked_in_at' => $ticket->checked_in_at->toIso8601String(),
        ], 'Check-in successful');
    }
}
