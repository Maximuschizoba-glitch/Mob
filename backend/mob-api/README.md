         # Mob API — Real-time City Discovery Platform

Backend API for **Mob**, a location-based mobile app for discovering events, casual happenings, and live vibes across Lagos, Nigeria. Content is ephemeral (24-hour expiry), geo-aware, and driven by real-time crowd signals.

Built for Gen Z / young adults (18-30), urban, social, mobile-first.

---

## Tech Stack

- **Framework:** Laravel 12 (PHP 8.2+)
- **Database:** MySQL 8
- **Cache / Queues:** Redis (production), file/sync drivers (development)
- **Authentication:** Laravel Sanctum (token-based, 30-day expiry)
- **Payments:** Paystack + Flutterwave (dual gateway, abstracted via PaymentService)
- **Push Notifications:** Firebase Cloud Messaging (FCM HTTP v1 API)
- **Media Storage:** Firebase Storage (client-side upload, URLs stored in DB)
- **Scheduling:** Laravel Task Scheduler
- **Timezone:** Africa/Lagos (WAT, UTC+1)
- **Currency:** NGN (Nigerian Naira)

---

## Requirements

- PHP 8.2+
- Composer
- MySQL 8
- Redis (production) or file driver (development)
- Firebase project with service account credentials (for FCM)

---

## Setup

```bash
# Clone the repository
git clone <repo-url> mob-api
cd mob-api

# Install dependencies
composer install

# Environment configuration
cp .env.example .env
# Edit .env — set DB_DATABASE, DB_USERNAME, DB_PASSWORD, etc.

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Seed the database (test users + demo data)
php artisan db:seed

# Start the development server
php artisan serve
```

### Test Accounts (after seeding)

| Email             | Password   | Role  |
|-------------------|------------|-------|
| admin@mob.test    | password   | Admin |
| host@mob.test     | password   | Host  |
| user@mob.test     | password   | User  |

---

## API Overview

**Base URL:** `/api/v1`

**Authentication:** Bearer token via `Authorization: Bearer {token}` header (Laravel Sanctum).

**Response format:**
```json
{
  "success": true,
  "message": "...",
  "data": { },
  "meta": { }
}
```

### Auth (10 endpoints)

| Method   | Path                        | Auth | Description                  |
|----------|-----------------------------|------|------------------------------|
| `POST`   | `/auth/register`            | No   | Register a new user          |
| `POST`   | `/auth/login`               | No   | Login and receive token      |
| `POST`   | `/auth/guest`               | No   | Create guest session         |
| `POST`   | `/auth/logout`              | Yes  | Revoke current token         |
| `GET`    | `/auth/user`                | Yes  | Get authenticated user       |
| `POST`   | `/auth/send-phone-otp`      | Yes  | Send phone verification OTP  |
| `POST`   | `/auth/verify-phone`        | Yes  | Verify phone with OTP        |
| `POST`   | `/auth/verify-email`        | Yes  | Verify email address         |
| `POST`   | `/auth/fcm-token`           | Yes  | Register FCM device token    |
| `DELETE` | `/auth/fcm-token`           | Yes  | Remove FCM device token      |

### Happenings / Feed (4 endpoints)

| Method   | Path                        | Auth | Description                      |
|----------|-----------------------------|------|----------------------------------|
| `GET`    | `/happenings`               | No   | List happenings (proximity feed) |
| `GET`    | `/happenings/map`           | No   | Map view (clustered pins)        |
| `GET`    | `/happenings/{uuid}`        | No   | Get single happening             |
| `POST`   | `/happenings`               | Yes  | Create a happening               |

### Snaps (2 endpoints)

| Method   | Path                              | Auth | Description              |
|----------|-----------------------------------|------|--------------------------|
| `POST`   | `/happenings/{uuid}/snaps`        | Yes  | Upload a snap            |
| `GET`    | `/happenings/{uuid}/snaps`        | Yes  | List snaps for happening |

### Tickets (3 endpoints)

| Method   | Path                        | Auth | Description              |
|----------|-----------------------------|------|--------------------------|
| `POST`   | `/tickets/purchase`         | Yes  | Purchase a ticket        |
| `GET`    | `/tickets`                  | Yes  | List user's tickets      |
| `GET`    | `/tickets/{uuid}`           | Yes  | Get ticket details       |

### Escrow (2 endpoints)

| Method   | Path                            | Auth | Description                    |
|----------|---------------------------------|------|--------------------------------|
| `GET`    | `/escrow/{uuid}`                | Yes  | View escrow details            |
| `POST`   | `/escrow/{uuid}/complete`       | Yes  | Host marks event complete      |

### Host Verification (2 endpoints)

| Method   | Path                            | Auth | Description                    |
|----------|---------------------------------|------|--------------------------------|
| `POST`   | `/host/verify`                  | Yes  | Submit verification request    |
| `GET`    | `/host/verification-status`     | Yes  | Check verification status      |

### Reports (1 endpoint)

| Method   | Path                              | Auth | Description              |
|----------|-----------------------------------|------|--------------------------|
| `POST`   | `/happenings/{uuid}/report`       | Yes  | Report a happening       |

### Admin (15 endpoints)

All admin routes require `admin` role.

| Method   | Path                                      | Description                      |
|----------|-------------------------------------------|----------------------------------|
| `GET`    | `/admin/dashboard`                        | Dashboard statistics             |
| `GET`    | `/admin/activity-log`                     | Admin activity log               |
| `GET`    | `/admin/verifications`                    | List verification requests       |
| `GET`    | `/admin/verifications/{id}`               | View verification details        |
| `POST`   | `/admin/verifications/{id}/approve`       | Approve host verification        |
| `POST`   | `/admin/verifications/{id}/reject`        | Reject host verification         |
| `GET`    | `/admin/reports`                          | List reported happenings         |
| `POST`   | `/admin/happenings/{id}/hide`             | Hide a happening                 |
| `POST`   | `/admin/happenings/{id}/reinstate`        | Reinstate a hidden happening     |
| `DELETE` | `/admin/happenings/{id}`                  | Delete a happening               |
| `GET`    | `/admin/escrows`                          | List all escrows                 |
| `GET`    | `/admin/escrows/{id}`                     | View escrow details              |
| `POST`   | `/admin/escrows/{id}/approve`             | Approve escrow release           |
| `POST`   | `/admin/escrows/{id}/reject`              | Reject escrow (trigger refund)   |
| `POST`   | `/admin/escrows/{id}/force-refund`        | Force refund all tickets         |

### Webhooks (2 endpoints)

No auth required — verified by gateway signature.

| Method   | Path                        | Description                      |
|----------|-----------------------------|----------------------------------|
| `POST`   | `/webhooks/paystack`        | Paystack payment webhook         |
| `POST`   | `/webhooks/flutterwave`     | Flutterwave payment webhook      |

### System (2 endpoints)

| Method   | Path          | Auth | Description                      |
|----------|---------------|------|----------------------------------|
| `GET`    | `/health`     | No   | Health check (DB, cache, queue)  |
| `GET`    | `/info`       | No   | API metadata and configuration   |

---

## Scheduled Commands

These run via `php artisan schedule:work` (development) or cron (production).

| Command                         | Frequency      | Description                                |
|---------------------------------|----------------|--------------------------------------------|
| `content:expire`                | Hourly         | Soft-delete expired happenings and snaps   |
| `happenings:update-vibes`       | Every 15 min   | Recalculate vibe scores and activity levels |
| `escrows:transition-held`       | Every 5 min    | Move escrows from COLLECTING to HELD       |
| `escrows:check-refunds`         | Every 30 min   | Process pending refunds via payment gateway |
| `happenings:notify-expiring`    | Every 30 min   | Push notify hosts of soon-to-expire content |

### Production Cron Entry

```
* * * * * cd /path/to/mob-api && php artisan schedule:run >> /dev/null 2>&1
```

---

## Rate Limiting

| Limiter    | Limit                          | Applied To                     |
|------------|--------------------------------|--------------------------------|
| `api`      | 60/min (auth), 30/min (guest)  | All API routes                 |
| `auth`     | 10/min per IP                  | Auth endpoints                 |
| `posting`  | 20/min per user                | Creating happenings and snaps  |
| `webhooks` | 100/min per IP                 | Payment webhook endpoints      |

---

## Environment Variables

See `.env.production.example` for a complete production template. Key variables:

```
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_DATABASE=mob

CACHE_STORE=file          # Use 'redis' in production
QUEUE_CONNECTION=sync     # Use 'redis' in production

PAYSTACK_SECRET_KEY=
FLUTTERWAVE_SECRET_KEY=
FLUTTERWAVE_ENCRYPTION_KEY=

FIREBASE_PROJECT_ID=
FIREBASE_CREDENTIALS_PATH=

SANCTUM_TOKEN_EXPIRATION=43200  # 30 days in minutes
```

---

## Architecture Notes

- **Service Layer:** Business logic lives in `app/Services/` (PaymentService, EscrowService, RefundService, VibeScoreService, etc.). Controllers are thin — validate, delegate, respond.
- **Enum-Driven Statuses:** All statuses, categories, and types use PHP 8.1+ backed enums (`app/Enums/`). No magic strings.
- **Escrow State Machine:** Ticketed events use a two-step fund release flow — host marks complete, then admin approves. Full audit trail via `escrow_events_log`.
- **Role-Based Access:** Three roles (user, host, admin) enforced via middleware. Guest mode allows browsing only.
- **UUID Public IDs:** All public-facing identifiers are UUIDs. Auto-increment IDs are internal only.
- **Content Expiration:** All happenings and snaps expire after 24 hours. Scheduled cleanup via soft deletes.
- **Idempotent Seeders:** All seeders use `updateOrCreate()` and can be run multiple times safely.
- **Event-Driven Notifications:** Push notifications dispatched via queued Laravel event listeners (5 events, 5 listeners).

---

## License

Proprietary. All rights reserved.

Designed and Developed by buuk Tech Solutions LTD
