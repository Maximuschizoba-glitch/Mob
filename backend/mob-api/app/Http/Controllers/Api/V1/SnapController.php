<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\HappeningStatus;
use App\Events\SnapAdded;
use App\Http\Requests\Snap\CreateSnapRequest;
use App\Http\Resources\SnapResource;
use App\Models\Happening;
use App\Services\MediaService;
use App\Services\VibeScoreService;
use Illuminate\Http\JsonResponse;

class SnapController extends BaseController
{
    public function __construct(
        private readonly MediaService $mediaService,
        private readonly VibeScoreService $vibeScoreService,
    ) {}

    public function store(CreateSnapRequest $request, string $happeningUuid): JsonResponse
    {
        \Log::info('Snap upload request', [
            'happening_uuid' => $happeningUuid,
            'all' => $request->all(),
            'files' => $request->allFiles(),
            'content_type' => $request->header('Content-Type'),
        ]);

        $happening = Happening::where('uuid', $happeningUuid)->first();

        if (! $happening) {
            return $this->errorResponse('Happening not found', null, 404);
        }

        if ($happening->status !== HappeningStatus::ACTIVE) {
            return $this->errorResponse('Cannot add snaps to this happening', null, 403);
        }

        if ($happening->expires_at->isPast()) {
            return $this->errorResponse('This happening has expired', null, 403);
        }



        if ($happening->starts_at && $happening->starts_at->isFuture()) {
            if ($request->user()->id !== $happening->user_id) {
                return $this->errorResponse(
                    'Snaps can only be added once this event goes live.',
                    null,
                    403
                );
            }
        }

        if (! $this->mediaService->validateMediaUrl($request->validated('media_url'))) {
            return $this->errorResponse('Invalid media URL', null, 422);
        }


        $thumbnailUrl = $request->validated('thumbnail_url')
            ?? $this->mediaService->generateThumbnailUrl($request->validated('media_url'));

        $snap = $happening->snaps()->create([
            'user_id' => $request->user()->id,
            'media_url' => $request->validated('media_url'),
            'media_type' => $request->validated('media_type'),
            'thumbnail_url' => $thumbnailUrl,
            'duration_seconds' => $request->validated('duration_seconds'),
            'expires_at' => $happening->expires_at,
        ]);

        $this->vibeScoreService->updateHappeningVibe($happening);

        event(new SnapAdded($snap, $happening));

        $snap->load('user');


        $happening->refresh();
        $happening->loadCount('snaps');

        return $this->successResponse(
            [
                'snap' => new SnapResource($snap),
                'happening_stats' => [
                    'vibe_score' => (float) $happening->vibe_score,
                    'activity_level' => $happening->activity_level?->value,
                    'snaps_count' => (int) $happening->snaps_count,
                ],
            ],
            'Snap added successfully',
            201
        );
    }

    public function index(string $happeningUuid): JsonResponse
    {
        $happening = Happening::where('uuid', $happeningUuid)->first();

        if (! $happening) {
            return $this->errorResponse('Happening not found', null, 404);
        }

        $snaps = $happening->snaps()
            ->where('expires_at', '>', now())
            ->with('user')
            ->orderByDesc('created_at')
            ->paginate(20);

        return $this->paginatedResponse($snaps, SnapResource::class, 'Snaps retrieved successfully');
    }
}
