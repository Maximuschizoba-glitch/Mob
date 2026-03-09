<?php

namespace App\Http\Requests\Snap;

use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class CreateSnapRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'media_url' => ['required', 'string', 'url', 'max:2048'],
            'media_type' => ['required', 'string', 'in:image,video'],
            'thumbnail_url' => ['nullable', 'string', 'url', 'max:2048'],
            'duration_seconds' => ['nullable', 'integer', 'min:1', 'max:30'],
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
