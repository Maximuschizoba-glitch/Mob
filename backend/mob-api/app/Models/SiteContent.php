<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;

class SiteContent extends Model
{
    protected $fillable = ['key', 'group', 'label', 'type', 'value', 'description', 'sort_order'];

    public static function getValue(string $key, string $default = ''): string
    {
        return Cache::remember("site_content_{$key}", 3600, function () use ($key, $default) {
            $content = static::where('key', $key)->first();
            return $content?->value ?? $default;
        });
    }

    public static function getGroup(string $group): array
    {
        return Cache::remember("site_content_group_{$group}", 3600, function () use ($group) {
            return static::where('group', $group)
                ->orderBy('sort_order')
                ->pluck('value', 'key')
                ->toArray();
        });
    }

    protected static function booted()
    {
        static::saved(function ($content) {
            Cache::forget("site_content_{$content->key}");
            Cache::forget("site_content_group_{$content->group}");
        });
    }
}
