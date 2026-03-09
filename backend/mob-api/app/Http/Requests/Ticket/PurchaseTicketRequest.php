<?php

namespace App\Http\Requests\Ticket;

use App\Enums\PaymentGateway;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Validation\Rule;

class PurchaseTicketRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'happening_uuid' => ['required', 'string', 'exists:happenings,uuid'],
            'quantity' => ['sometimes', 'integer', 'min:1', 'max:10'],
            'payment_gateway' => ['required', 'string', Rule::in(PaymentGateway::cases())],
            'callback_url' => ['nullable', 'string', 'url'],
        ];
    }

    protected function failedValidation(Validator $validator): void
    {
        throw new HttpResponseException(response()->json([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422));
    }
}
