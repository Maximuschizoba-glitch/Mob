<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\ActivityLevel;
use App\Enums\HappeningCategory;
use App\Enums\HappeningStatus;
use App\Http\Requests\Happening\CreateHappeningRequest;
use App\Http\Requests\Happening\FeedQueryRequest;
use App\Http\Requests\Happening\MapQueryRequest;
use App\Http\Requests\Happening\UpdateHappeningRequest;
use App\Http\Resources\HappeningMapResource;
use App\Http\Resources\HappeningResource;
use App\Models\Happening;
use App\Services\LocationService;
use App\Services\MediaService;
use App\Services\VibeScoreService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;

class HappeningController extends BaseController
{
    public function __construct(
        private readonly LocationService $locationService,
        private readonly MediaService $mediaService,
        private readonly VibeScoreService $vibeScoreService,
    ) {}

    public function store(CreateHappeningRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();




        $expiryHours = config('mob.content_expiry_hours', 24);
        $startsAt = !empty($validated['starts_at'])
            ? Carbon::parse($validated['starts_at'])
            : null;

        $expiresAt = ($startsAt !== null && $startsAt->isFuture())
            ? $startsAt->copy()->addHours($expiryHours)
            : Carbon::now()->addHours($expiryHours);

        $happening = Happening::create([
            'user_id' => $user->id,
            ...$validated,
            'expires_at' => $expiresAt,
            'status' => HappeningStatus::ACTIVE,
            'activity_level' => ActivityLevel::LOW,
            'vibe_score' => 0,
        ]);

        if ($request->has('snaps')) {
            foreach ($request->input('snaps') as $snapData) {
                if (! $this->mediaService->validateMediaUrl($snapData['media_url'])) {
                    return $this->errorResponse('Invalid media URL provided', null, 422);
                }

                $happening->snaps()->create([
                    'user_id' => $user->id,
                    'media_url' => $snapData['media_url'],
                    'media_type' => $snapData['media_type'],
                    'thumbnail_url' => $this->mediaService->generateThumbnailUrl($snapData['media_url']),
                    'expires_at' => $expiresAt,
                ]);
            }

            $this->vibeScoreService->updateHappeningVibe($happening);
        }

        $happening->load(['user', 'user.hostProfile', 'snaps']);
        $happening->loadCount('snaps');

        return $this->successResponse(
            new HappeningResource($happening),
            'Happening created successfully',
            201
        );
    }

    public function index(FeedQueryRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $radiusKm = $request->validated('radius_km', config('mob.default_feed_radius_km', 10));
        $perPage = $validated['per_page'] ?? 20;

        $query = Happening::query()
            ->select('happenings.*');

        $this->locationService->buildHaversineQuery(
            $query,
            (float) $validated['latitude'],
            (float) $validated['longitude'],
            (float) $radiusKm
        );

        $query->where('status', HappeningStatus::ACTIVE)
            ->where('expires_at', '>', now());

        $query->when($request->validated('category'), function ($query, $category) {
            $query->where('category', HappeningCategory::from($category));
        });

        $query->with([
                'user',
                'user.hostProfile',
                'snaps' => function ($query) {
                    $query->where('expires_at', '>', now())
                        ->orderBy('created_at')
                        ->limit(1);
                },
            ])
            ->withCount('snaps')
            ->orderBy('distance_km')
            ->orderByDesc('vibe_score')
            ->orderByDesc('created_at');

        $happenings = $query->paginate($perPage);

        return $this->paginatedResponse($happenings, HappeningResource::class, 'Happenings retrieved successfully');
    }

    public function show(string $uuid): JsonResponse
    {
        $happening = Happening::query()
            ->where('uuid', $uuid)
            ->where('status', '!=', HappeningStatus::HIDDEN)
            ->with([
                'user',
                'user.hostProfile',
                'snaps' => function ($query) {
                    $query->where('expires_at', '>', now())
                        ->orderByDesc('created_at');
                },
            ])
            ->withCount('snaps')
            ->first();

        if (! $happening) {
            return $this->errorResponse('Happening not found', null, 404);
        }

        return $this->successResponse(
            new HappeningResource($happening),
            'Happening retrieved successfully'
        );
    }

    public function myHappenings(): JsonResponse
    {
        $user = request()->user();

        $happenings = Happening::query()
            ->where('user_id', $user->id)
            ->with([
                'user',
                'user.hostProfile',
                'snaps' => function ($query) {
                    $query->orderBy('created_at')
                        ->limit(1);
                },
            ])
            ->withCount('snaps')
            ->orderByDesc('created_at')
            ->get();

        return $this->successResponse(
            HappeningResource::collection($happenings),
            'My happenings retrieved successfully'
        );
    }




    public function destroy(string $uuid): JsonResponse
    {
        $user = request()->user();

        $happening = Happening::query()
            ->where('uuid', $uuid)
            ->where('user_id', $user->id)
            ->first();

        if (! $happening) {
            return $this->errorResponse('Happening not found or you do not own it', null, 404);
        }

        $happening->delete();

        return $this->successResponse(null, 'Happening deleted successfully');
    }




    public function update(UpdateHappeningRequest $request, string $uuid): JsonResponse
    {
        $user = $request->user();

        $happening = Happening::query()
            ->where('uuid', $uuid)
            ->where('user_id', $user->id)
            ->first();

        if (! $happening) {
            return $this->errorResponse('Happening not found or you do not own it', null, 404);
        }

        if ($happening->status !== HappeningStatus::ACTIVE) {
            return $this->errorResponse('Only active happenings can be updated', null, 422);
        }

        $happening->update($request->validated());
        $happening->load(['user', 'user.hostProfile', 'snaps']);
        $happening->loadCount('snaps');

        return $this->successResponse(
            new HappeningResource($happening),
            'Happening updated successfully'
        );
    }




    public function endEvent(string $uuid): JsonResponse
    {
        $user = request()->user();

        $happening = Happening::query()
            ->where('uuid', $uuid)
            ->where('user_id', $user->id)
            ->first();

        if (! $happening) {
            return $this->errorResponse('Happening not found or you do not own it', null, 404);
        }

        if ($happening->status !== HappeningStatus::ACTIVE) {
            return $this->errorResponse('Only active happenings can be ended', null, 422);
        }

        $happening->update([
            'status' => HappeningStatus::COMPLETED,
            'expires_at' => now(),
        ]);

        $happening->load(['user', 'user.hostProfile', 'snaps']);
        $happening->loadCount('snaps');

        return $this->successResponse(
            new HappeningResource($happening),
            'Happening ended successfully'
        );
    }

    public function map(MapQueryRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $query = Happening::query()
            ->select('id', 'uuid', 'title', 'category', 'type', 'latitude', 'longitude', 'activity_level', 'vibe_score', 'is_ticketed', 'ticket_price', 'expires_at', 'status');

        $this->locationService->filterByBoundingBox(
            $query,
            (float) $validated['ne_lat'],
            (float) $validated['ne_lng'],
            (float) $validated['sw_lat'],
            (float) $validated['sw_lng']
        );

        $query->where('status', HappeningStatus::ACTIVE)
            ->where('expires_at', '>', now());

        $query->when($request->validated('category'), function ($query, $category) {
            $query->where('category', HappeningCategory::from($category));
        });

        $happenings = $query->with([
                'snaps' => function ($query) {
                    $query->where('expires_at', '>', now())
                        ->orderBy('created_at')
                        ->limit(1);
                },
            ])
            ->withCount('snaps')
            ->orderByDesc('vibe_score')
            ->limit(100)
            ->get();

        return $this->successResponse(
            HappeningMapResource::collection($happenings),
            'Map happenings retrieved successfully'
        );
    }
}
