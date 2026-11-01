# Areana API contract (mobile)

The Flutter app consumes the **Areana Nest API** — the same API as the
user-web player app (`areana-user-web`, `lib/player.ts`) — through a
single Dio instance + `ApiResult<T>`. Endpoint constants live in
`lib/core/consts/api_endpoints.dart`; do not hardcode a host in a client.

Base URL comes from flavor config (`config.development.json` /
`config.production.json`) via `--dart-define-from-file`. It is compiled
in, not read at runtime: changing a config file requires a **full
rebuild**, hot reload does not pick it up. The base URL must end with
`/api/` (the API's global prefix), with a trailing slash.

Current development config (Nov 1, 2026):

```json
{
  "FLAVOR": "development",
  "API_BASE_URL": "http://10.31.147.229:3000/api/",
  "USE_MOCK_API": "false"
}
```

That IP is the Mac's LAN IP — `localhost` on a phone means the phone
itself, not the Mac. The IP changes with the network; update
`config.development.json` when it does. Production is not yet configured
for the live API (still a placeholder host with mock on) — do not use
the production flavor for live testing.

All paths below are relative to the base URL. Auth-protected routes
expect:

```http
Authorization: Bearer <accessToken>
```

The interceptor attaches it from secure storage on every request, and
on 401 does a single-flight `POST auth/refresh`, rotates the pair,
retries once, and only clears the session on a refresh 401.

Success responses use HTTP `2xx`. Error responses use:

```json
{
  "message": "Human readable error",
  "statusCode": 401
}
```

`message` is required for UI dialogs. Some errors also carry field
`errors` and, on 429, `retryAfterSeconds` / `resetsAt`.

## Numbers that arrive as strings

Prisma Decimal fields serialize as **strings**, not numbers
(`totalPrice: "18000"`, court `pricePerHour: "3000"`). Models must parse
num **or** String (`int.tryParse` / `double.tryParse`) — a plain
`as num` cast crashes. This bit the bookings list in live testing.

## Pagination

Listings never return a bare array:

- **OffsetPage** (`?page&limit`, `items, total, page, limit, totalPages,
  hasMore`): venues, courts, games board, my bookings.
- **CursorPage** (`?cursor&limit`, `items, nextCursor, total?`):
  favorites, notifications, venue/court reviews.

Slot search is bounded, not paginated.

## Auth — passwordless email OTP, same as user-web `/auth`

No passwords, no social login, no forgot-password flow. Single screen:
email → 6-digit code → signup (new accounts only) → done / home.

### `POST auth/request-otp`

```json
{ "email": "you@example.com" }
```

Success `201`: `{ "message", "expiresAt", "ttlSeconds": 600 }`.
Fresh random code per request, 10-minute expiry, max 5 codes/hour/email.
A 503 means mail send failed and **no new code was issued** — a previous
live code still works. A 429 carries `retryAfterSeconds` / `resetsAt`.

### `POST auth/verify-otp`

```json
{ "email": "you@example.com", "code": "123456" }
```

For a new account, add `name` (required), `phone` (required), `city`
(optional), `referralCode` (optional). The code is **not** consumed when
the server replies that name/phone are missing, so the same code is
reused for the signup submit.

Success `201`:

```json
{
  "accessToken": "…",
  "refreshToken": "…",
  "user": {
    "id": "…",
    "email": "you@example.com",
    "name": "…",
    "role": "player",
    "permissions": ["bookings.create", "bookings.read", "reviews.write", "favorites.manage", "games.manage", "referrals.read"]
  },
  "welcomePromoCode": null,
  "referralStatus": "none",
  "expiresAt": "…",
  "ttlSeconds": 600
}
```

Tokens live in `flutter_secure_storage` (user profile JSON stays in
SharedPreferences). Access tokens are short-lived (~15 min).

### `POST auth/refresh`

```json
{ "refreshToken": "…" }
```

Rotates the pair; the old pair must be discarded. Presenting a
just-rotated token again trips server reuse detection and revokes **all**
sessions — that is why refresh is single-flight in the interceptor.

### `POST auth/logout`

```json
{ "refreshToken": "…" }
```

Best-effort: the app clears the local session regardless of the result.
`GET auth/sessions` and `POST auth/logout-all` also exist.

## Discovery (public)

- `GET venues` — browse, with `lat`, `lng`, `sort=distance` (Haversine),
  plus sport / city / price filters. `GET venues/cities`,
  `GET venues/surfaces`, `GET sports`, `GET amenities`, `GET banners`.
- `GET venues/:id` — arena detail. `GET venues/:id/courts`,
  `GET venues/:id/reviews` (cursor), `POST venues/:id/report`,
  `GET venues/:id/report/me`, `POST venues/:id/events`
  (`{ "type": "view" | "click" | "court_view" }`).
- `GET courts`, `GET courts/:id` — court browse / detail (mirrors arena
  detail). `GET courts/:id/reviews` (cursor).
- `GET courts/:courtId/availability?date=YYYY-MM-DD` — windows + slots
  with `available`, `reason` (`past` / `too_late` / `booked` …), `price`,
  `peak`, `deal`.
- `GET search/slots` — slot search across venues/courts.

## Bookings (authenticated)

- `POST bookings` — create (court-first, pay-at-venue only, promo via
  `POST bookings/validate-promo`). A 409 means the slot was taken.
- `GET bookings/me?filter=upcoming|past&page=&limit=` — my bookings
  (offset paging). Items carry nested `court` and `venue` objects.
- `GET bookings/:id`, `POST bookings/:id/cancel`,
  `POST bookings/:id/reschedule`, `POST bookings/:id/reschedule/withdraw`.
- `GET bookings/reschedules/pending` (owner-facing; kept for completeness).
- `POST bookings/:id/share`, `GET bookings/shared/:code`,
  `POST bookings/shared/:code/join` — group share links.
- `POST reviews` — one review per completed booking.

## Favorites (authenticated, cursor paging)

- `GET favorites`, `POST favorites` (`{ "venueId" }`),
  `DELETE favorites/:venueId`, `GET favorites/check`.

## Games board (public list, authenticated join/create)

User-web `/games`. There is **no chat** in the app — Games replaced the
old Messages/Chat feature, which was deleted.

- `GET game-posts`, `GET game-posts/:id`,
  `POST game-posts/:id/join`, `POST game-posts/:id/leave`,
  `POST game-posts/:id/requests/:participantId/accept|reject`.
- Creating a game is done from a booking (see the Games feature).

## Waitlist (authenticated)

- `GET waitlist`, `GET waitlist/mine`, `GET|DELETE waitlist/:id`.
  Note: in user-web, waitlist join from a booked slot is arena-only;
  the court page does not offer it yet.

## Profile / referrals / notifications (authenticated)

- `GET users/me`, `PATCH users/me` (name / phone / city only),
  `DELETE users/me` (anonymises the account in place).
- `GET users/me/device-tokens` (+ POST / DELETE by id) — FCM device
  tokens. The FCM service itself is unchanged by the API migration.
- `GET referrals/me`.
- `GET notifications` (cursor paging, `?limit&cursor`),
  `GET notifications/unread-count`,
  `PATCH notifications/:id/read`, `PATCH notifications/read-all`.
- There is **no** `/profile` endpoint — it is `/users/me`. Do not
  reintroduce `/profile` constants.

## Logging

Every Dio call is logged in debug builds only, via
`ApiLogInterceptor` + the `logger` package: method + full endpoint URL,
query, request body, response/error body, and duration. Headers are
never logged, and OTP codes, passwords, and access / refresh / device
tokens are redacted as `***REDACTED***`. Do not use Dio's built-in
`LogInterceptor` — it prints secrets in the clear.

## Mock mode (kept deliberately, auth only)

`USE_MOCK_API` is a compile-time dart-define. When true, repositories
serve delayed mock data instead of Dio. After the migration, only the
**auth** repository still has a mock branch
(`lib/core/mock/mock_auth_data.dart` + `mock_delay.dart`, mock OTP
`123456`, mock returning account `alex@pitchside.app`). All other mock
files and the old Messages feature were deleted in the Section 8
cleanup. Development runs with mock **off**; production still has it on
until its base URL is configured.
