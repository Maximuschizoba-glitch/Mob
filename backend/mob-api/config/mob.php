<?php

return [




    'platform_commission_rate' => (float) env('MOB_COMMISSION_RATE', 0.10),




    'content_expiry_hours' => (int) env('MOB_CONTENT_EXPIRY_HOURS', 24),




    'default_feed_radius_km' => (int) env('MOB_DEFAULT_FEED_RADIUS_KM', 10),




    'max_snaps_per_post' => (int) env('MOB_MAX_SNAPS_PER_POST', 5),

    'max_snap_file_size_mb' => (int) env('MOB_MAX_SNAP_FILE_SIZE_MB', 10),




    'reports_to_auto_hide' => (int) env('MOB_REPORTS_TO_AUTO_HIDE', 3),




    'refund_window_hours' => (int) env('MOB_REFUND_WINDOW_HOURS', 48),




    'currency' => env('MOB_CURRENCY', 'NGN'),

    'phone_country_code' => env('MOB_PHONE_COUNTRY_CODE', '+234'),

];
