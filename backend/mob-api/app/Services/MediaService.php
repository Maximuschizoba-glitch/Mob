<?php

namespace App\Services;

class MediaService
{
    private const ALLOWED_URL_PREFIXES = [
        'https://firebasestorage.googleapis.com/',
        'https://storage.googleapis.com/',
    ];

    private const ALLOWED_MEDIA_TYPES = [
        'image',
        'video',
    ];

    public function validateMediaUrl(string $url): bool
    {
        if (! filter_var($url, FILTER_VALIDATE_URL)) {
            return false;
        }

        foreach (self::ALLOWED_URL_PREFIXES as $prefix) {
            if (str_starts_with($url, $prefix)) {
                return true;
            }
        }

        return false;
    }

    public function validateMediaType(string $mediaType): bool
    {
        return in_array($mediaType, self::ALLOWED_MEDIA_TYPES, true);
    }


    public function generateThumbnailUrl(string $mediaUrl): string
    {
        return $mediaUrl;
    }
}
