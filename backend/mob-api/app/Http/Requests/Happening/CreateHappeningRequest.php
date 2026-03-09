<?php

namespace App\Http\Requests\Happening;

use App\Enums\HappeningCategory;
use App\Enums\HappeningType;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Validation\Rule;

class CreateHappeningRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string', 'max:2000'],
            'category' => ['required', 'string', Rule::in(HappeningCategory::cases())],
            'type' => ['required', 'string', Rule::in(HappeningType::cases())],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'radius_meters' => ['nullable', 'integer', 'min:100', 'max:5000'],
            'address' => ['required', 'string', 'max:500'],
            'starts_at' => ['nullable', 'date', 'after:now'],
            'ends_at' => ['nullable', 'date', 'after:starts_at'],
            'is_ticketed' => ['nullable', 'boolean'],
            'ticket_price' => ['required_if:is_ticketed,true', 'nullable', 'numeric', 'min:100'],
            'ticket_quantity' => ['required_if:is_ticketed,true', 'nullable', 'integer', 'min:1'],
            'snaps' => ['nullable', 'array', 'max:' . config('mob.max_snaps_per_post', 5)],
            'snaps.*.media_url' => ['required_with:snaps', 'string', 'url', 'max:2048'],
            'snaps.*.media_type' => ['required_with:snaps', 'string', 'in:image,video'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            $type = $this->input('type');

            if ($type === HappeningType::EVENT->value && ! $this->filled('starts_at')) {
                $validator->errors()->add('starts_at', 'The starts_at field is required for events.');
            }

            if ($this->boolean('is_ticketed') && $type !== HappeningType::EVENT->value) {
                $validator->errors()->add('is_ticketed', 'Ticketing is only allowed for events.');
            }

            if ($type === HappeningType::CASUAL->value && $this->filled('radius_meters')) {
                $snaps = $this->input('snaps');
                if (empty($snaps) || ! is_array($snaps) || count($snaps) < 1) {
                    $validator->errors()->add('snaps', 'Casual area-based happenings require at least one snap.');
                }
            }
        });
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
