# Pitchside API contract

Hand this file to the backend developer. The Flutter app already consumes these shapes through Dio + `ApiResult<T>`.

While `USE_MOCK_API` is `"true"` in `config.*.json`, the app uses delayed mock data (2 seconds). When the real API is ready:

1. Deploy these endpoints under the flavor base URL.
2. Set `USE_MOCK_API` to `"false"`.
3. Point `API_BASE_URL` at the real host (keep the trailing `/`).
4. No Flutter feature rewrite is required.

Base URL examples:

- Development: `https://api-dev.example.com/`
- Production: `https://api.example.com/`

All paths below are relative to the base URL. Auth-protected routes expect:

```http
Authorization: Bearer <access_token>
```

Success responses should use HTTP `2xx`. Error responses should prefer:

```json
{
  "message": "Human readable error",
  "errors": {
    "email": ["Already taken"]
  }
}
```

`message` is required for UI dialogs. `errors` is optional field-level detail.

---

## Auth session payload (shared)

Every successful auth endpoint below returns the same shape. The app stores both fields and keeps `user` in app-wide `SessionCubit` / `UserModel`.

```json
{
  "access_token": "jwt-or-opaque-token",
  "user": {
    "id": "user_1",
    "name": "Alex Player",
    "email": "you@example.com",
    "phone": "03001234567",
    "avatar_url": null,
    "provider": "email"
  }
}
```

| Field | Type | Notes |
| --- | --- | --- |
| `access_token` | string | Required. Sent as `Authorization: Bearer …` |
| `user.id` | string | App user id (not the Google/Apple uid) |
| `user.avatar_url` | string\|null | Optional; UI falls back to initials (`Muhammad Arslan` → `MA`) |
| `user.provider` | string\|null | `email` \| `google` \| `apple` |

---

## Auth

### `POST auth/login`

Request:

```json
{
  "identifier": "you@example.com",
  "password": "secret123"
}
```

`identifier` may be email or phone. Success `200` → **session payload**.

---

### `POST auth/signup`

Creates a pending account and emails an OTP. Does **not** return `access_token` yet.

Request:

```json
{
  "name": "Alex Player",
  "phone": "03001234567",
  "email": "you@example.com",
  "password": "secret123"
}
```

Success `200` / `201`:

```json
{ "message": "OTP sent" }
```

### `POST auth/signup/verify-otp`

Request:

```json
{
  "email": "you@example.com",
  "otp": "123456"
}
```

Success `200` → **session payload**. App then calls `GET profile` and opens the dashboard.

---

### `POST auth/social`

Client gets account info from Google / Apple (including provider uid), then posts:

```json
{
  "provider": "google",
  "provider_uid": "google-sub-or-uid",
  "email": "alex.google@pitchside.app",
  "name": "Alex Google",
  "avatar_url": null,
  "id_token": "optional-id-token-for-server-verify"
}
```

`provider` is `google` or `apple`.

Backend verifies the token / uid, checks DB:

- existing social link → login
- new → create account

Both cases return **session payload** (`200` / `201`).

---

### Forgot password (3 steps)

#### `POST auth/forgot-password/send-otp`

```json
{ "email": "you@example.com" }
```

Success `200`: `{ "message": "OTP sent" }`

#### `POST auth/forgot-password/verify-otp`

```json
{
  "email": "you@example.com",
  "otp": "123456"
}
```

Success `200`: `{ "message": "OTP verified" }`

#### `POST auth/forgot-password/reset`

```json
{
  "email": "you@example.com",
  "otp": "123456",
  "password": "newSecret123"
}
```

Success `200` → **session payload**. App stores the token, calls `GET profile`, then opens the dashboard.

Mock OTP while `USE_MOCK_API` is true: `123456`.

---

## Profile

Requires auth.

### `GET profile`

Success `200` — bare user or wrapped:

```json
{
  "user": {
    "id": "user_1",
    "name": "Alex Player",
    "email": "you@example.com",
    "phone": "03001234567",
    "avatar_url": null,
    "provider": "email"
  }
}
```

### `PUT profile`

Request (send only fields to change):

```json
{
  "name": "Alex Player",
  "phone": "03001234567",
  "email": "you@example.com",
  "avatar_url": null
}
```

Success `200` — same user object as GET. App updates `SessionCubit` / local cache.

---

## Home

### `GET venues/search?q=`

Auth optional. Query param `q` is the search string.

Success `200`:

```json
{
  "places": [
    {
      "id": "pk-lahore",
      "primary_text": "Lahore",
      "secondary_text": "Punjab, Pakistan"
    }
  ],
  "venues": [ { "...": "same shape as popular venue" } ]
}
```

`places` is Google Places–style autocomplete (mock today). Selecting a place returns the user to Explore filtered by that area. Selecting a venue opens venue detail.

---

### `GET venues/popular`

Auth optional for browsing.

Success `200` — either a bare array or a wrapped list:

```json
{
  "data": [
    {
      "id": "arena-one",
      "name": "Arena One Padel Club",
      "sport": "Padel",
      "location": "DHA Phase 6, Karachi",
      "price_from": 3000,
      "amenities": ["Glass courts", "Floodlit", "Parking"],
      "next_slot": "Today, 7:00 PM",
      "hero_color": "#1B4B7A"
    }
  ]
}
```

Field notes:

| Field | Type | Notes |
| --- | --- | --- |
| `id` | string | Stable venue id |
| `name` | string | Display title |
| `sport` | string | Badge label |
| `location` | string | City / area line |
| `price_from` | number | Hourly price in PKR, integer preferred |
| `amenities` | string[] | Chip labels |
| `next_slot` | string | Short human text for now |
| `description` | string | Detail page about copy |
| `rating` | number | 0–5 average |
| `review_count` | number | Review count for detail |
| `open_hours` | string | e.g. `6:00 AM – 12:00 AM` |
| `courts_label` | string | e.g. `4 glass courts` |
| `hero_color` | string | Hex `#RRGGBB` used as card hero fallback |
| `latitude` | number | Map marker latitude (WGS84) |
| `longitude` | number | Map marker longitude (WGS84) |
| `image_urls` | string[] | One or more court/venue photo URLs for the detail carousel |

---

## Booking

### `GET venues/{venueId}/availability`

Auth optional while browsing; required before `POST bookings`.

Success `200`:

```json
{
  "courts": [
    { "id": "c1", "name": "Court 1", "note": "Indoor" },
    { "id": "c2", "name": "Court 2", "note": "Glass" }
  ],
  "dates": [
    {
      "id": "d1",
      "weekday": "Wed",
      "day": "28",
      "month": "Oct",
      "full_label": "Wed 28 Oct"
    }
  ],
  "durations": ["60 min", "90 min", "120 min"],
  "slots": [
    { "id": "s1", "label": "6:00 PM", "price": 4500, "status": "open" },
    { "id": "s5", "label": "10:00 PM", "price": 4500, "status": "booked" }
  ]
}
```

| Field | Type | Notes |
| --- | --- | --- |
| `courts[].note` | string | Short court tag (Indoor / Glass) |
| `slots[].price` | number | Slot price in PKR |
| `slots[].status` | string | `open` or `booked` |

---

### `POST bookings`

Requires auth.

Request:

```json
{
  "venue_id": "arena-one",
  "court_id": "c2",
  "date_id": "d1",
  "slot_id": "s2",
  "duration": "60 min",
  "pay_at_ground": true
}
```

Success `201` or `200`:

```json
{
  "code": "PS-48213",
  "venue_name": "Arena One Padel Club",
  "sport": "Padel",
  "location": "DHA Phase 6, Karachi",
  "date_label": "Wed 28 Oct 2026",
  "time_label": "7:00 PM to 8:00 PM",
  "court_label": "Court 2, Glass",
  "duration_label": "60 min",
  "amount_due": 4500,
  "pay_at_ground": true
}
```

Guest flow in the app: pick slot → checkout → auth bottom sheet → login/signup with `?next=checkout` → confirm → confirmed screen. Signed-in users skip the sheet and call this endpoint directly.

---

### `GET bookings/mine`

Requires auth. Returns the signed-in user’s bookings (upcoming + past).

Success `200`:

```json
{
  "data": [
    {
      "id": "bk-1",
      "code": "PS-48213",
      "venue_id": "arena-one",
      "venue_name": "Arena One Padel Club",
      "sport": "Padel",
      "location": "DHA Phase 6, Karachi",
      "date_label": "Thu 29 Oct 2026",
      "time_label": "7:00 PM to 8:00 PM",
      "court_label": "Court 2, Glass",
      "duration_label": "60 min",
      "amount_due": 3000,
      "pay_at_ground": true,
      "status": "upcoming",
      "hero_color": "#1B4B7A",
      "image_url": "https://..."
    }
  ]
}
```

`status`:
- Upcoming tab: `confirmed` | `pending`
- Past tab: `completed` | `cancelled`

---

## Session rules the app already implements

- Login / social / signup verify-otp / forgot reset success → store token + `UserModel`, then `GET profile`, then dashboard.
- Signup and forgot send/verify OTP are intermediate steps (no token until final success).
- Cold start → restore session before routing. Authenticated users open Home.
- Dio interceptor adds `Authorization: Bearer <token>` when present.
- Profile get/update refreshes the same `UserModel` everywhere (`context.watch<SessionCubit>()`).
- Profile logout clears token + user and returns to Splash.
- Guest browsing is allowed without a token.
- Guests can pick a slot; confirming a booking requires auth.
- Google/Apple native SDKs are behind `SocialAuthService` (mock while `USE_MOCK_API` is true).

---

## Flutter switch from mock → real

```json
{
  "FLAVOR": "development",
  "API_BASE_URL": "https://your-real-api.example.com/",
  "USE_MOCK_API": "false"
}
```

Mock sources to delete later (optional cleanup):

- `lib/core/mock/mock_delay.dart`
- `lib/core/mock/mock_auth_data.dart`
- `lib/core/mock/mock_home_data.dart`
- `lib/core/mock/mock_booking_data.dart`
- `lib/core/mock/mock_profile_data.dart`
- `MockSocialAuthService` in `lib/core/services/social_auth_service.dart`
- repository branches that check `AppConfig.useMockApi`
