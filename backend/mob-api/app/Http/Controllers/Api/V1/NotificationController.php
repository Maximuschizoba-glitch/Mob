<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends BaseController
{



    public function index(Request $request): JsonResponse
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->paginate(20);

        return $this->paginatedResponse(
            $notifications,
            NotificationResource::class,
            'Notifications retrieved successfully'
        );
    }




    public function markAsRead(Request $request, string $uuid): JsonResponse
    {
        $notification = Notification::where('uuid', $uuid)
            ->where('user_id', $request->user()->id)
            ->first();

        if (! $notification) {
            return $this->errorResponse('Notification not found', null, 404);
        }

        if (! $notification->read_at) {
            $notification->read_at = now();
            $notification->save();
        }

        return $this->successResponse(
            new NotificationResource($notification),
            'Notification marked as read'
        );
    }




    public function markAllAsRead(Request $request): JsonResponse
    {
        Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return $this->successResponse(null, 'All notifications marked as read');
    }




    public function unreadCount(Request $request): JsonResponse
    {
        $count = Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->count();

        return $this->successResponse(
            ['count' => $count],
            'Unread notification count retrieved successfully'
        );
    }
}
