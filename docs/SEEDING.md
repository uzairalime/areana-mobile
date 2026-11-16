# Seed demo Football venues

The public `GET /api/venues` endpoint lists approved database records. It
cannot create venues. The backend's existing `npm run db:seed` creates
roles, badges, settings and an optional admin; it does not create venues.

From this mobile repository, use the dependency-free Node seeder against
the running API. Node 20 or newer is required. Preview all records first:

```bash
node tool/seed_football_venues.mjs --dry-run
```

It prepares 20 clearly labelled demo Football venues: 8 in Lahore, 6 in
Karachi, 4 in Islamabad and 2 in Rawalpindi. Each has approximate demo
coordinates, amenities and two courts (5v5 and 7v7), hourly PKR pricing,
and a 06:00–23:00 schedule. Availability is computed by the API from court
hours; the seed does not create bookings, reviews or images.

To write the records, supply the existing API admin credentials through
environment variables. The URL defaults to `config.development.json`;
`API_BASE_URL` overrides it. For example, in zsh:

```bash
export API_BASE_URL='https://eat-mins-percent-safari.trycloudflare.com/api/'
read 'ADMIN_EMAIL?Admin email: '
read -s 'ADMIN_PASSWORD?Admin password: '
export ADMIN_EMAIL ADMIN_PASSWORD
node tool/seed_football_venues.mjs
unset ADMIN_EMAIL ADMIN_PASSWORD
```

The script creates a dedicated active demo owner, creates missing venues
and courts, submits drafts, approves pending seed venues using the admin
account, and verifies that all 20 venues appear in public Football browse.
Existing matching records are reused on subsequent runs. Rejected or
suspended seed venues require manual resolution; their status is preserved.
Run only one seeder instance at a time because the API has no unique
constraint on venue or court names.

The generated demo owner password is saved before account creation in
`.seed-football-owner.json`, with owner-only file permissions. This file is
ignored by Git. Keep it for repeat runs. You can instead provide
`SEED_OWNER_EMAIL` and `SEED_OWNER_PASSWORD` through the environment; use the
same credentials on subsequent runs. An existing account is never assigned
a new password or role by this script.

If a request fails, the script stops. Rerun with the same owner credentials
to reuse successfully created records and complete the remaining records.

Local verification:

```bash
node --test tool/seed_football_venues.test.mjs
```
