<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\ResourceCollection;

class HappeningCollection extends ResourceCollection
{
    public $collects = HappeningResource::class;

    public function toArray(Request $request): array
    {
        return [
            'data' => $this->collection,
        ];
    }

    public function with(Request $request): array
    {
        return [
            'meta' => [
                'filters_applied' => array_filter([
                    'category' => $request->query('category'),
                    'radius_km' => $request->query('radius_km'),
                ]),
            ],
        ];
    }
}
