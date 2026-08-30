# ShipGo + Supabase — Setup Notes

**Project:** `utjfmriqgcinrgqzyzci` (https://supabase.com/dashboard/project/utjfmriqgcinrgqzyzci)
**Status:** Connected and verified live — `shipping-point.html` and
`app-monitoring.html` both read/write real Supabase data, confirmed end to
end against the deployed site and the live database.

Phase 1 covers: master data for `shipping-point.html` (Distribution Centers,
Depots, Staging Bays, District/route coverage) and `app-monitoring.html`
(Drivers, Devices, version history).

Not yet modeled or wired: Auth (still the shared PIN), Shipment Planning,
Live/History Tracking, Feature Config, Group/Role, User Management. These
stay on mock data until a later phase.

## How the connection works

- **`api/config.js`** — a tiny serverless endpoint that hands the browser
  `SUPABASE_URL` / `SUPABASE_ANON_KEY` from Vercel's Environment Variables.
  Both values are safe to expose client-side (Supabase's anon/publishable key
  is designed for this — access is enforced by RLS, not by keeping the key
  secret).
- **`supabase-client.js`** — shared helper, fetches `/api/config` once and
  creates the `supabase-js` client. Resolves to `null` if the env vars aren't
  set, which pages treat as "fall back to demo data" rather than an error.
- **`shipping-point.html`** — fetches Distribution Centers, Depots, Staging
  Bays, Routes, and Coverage, reshaped into the exact in-memory shape the
  page always used. The one real write — assigning/unassigning a Staging
  Bay's owner (`setBayOwner`) — upserts/deletes a row in
  `staging_bay_coverage`, with the "must unassign before reassigning" rule
  enforced before the write.
- **`app-monitoring.html`** — fetches Distribution Centers and
  Drivers-embedded-with-their-Device (`drivers?select=*,devices(*)`, using
  PostgREST's automatic FK embedding) into the page's original flat
  driver+device row shape. Version history is lazy-loaded from
  `device_version_history` only when a device's Detail modal is opened. The
  Detail modal now has a real **Edit mode** (added — the original page was
  read-only): Shipping Point and App Version become editable, "Simpan"
  writes both `drivers.dc_id` and `devices.app_version` via
  `client.from(...).update(...)`. Verified with a real write-then-revert
  round trip against the live database (confirmed via a fresh REST call
  independent of the page).

Both pages fall back to their original hardcoded `MOCK_*` arrays if Supabase
isn't configured or a fetch fails, so neither ever hard-breaks.

## Schema notes — corrected after reading the actual pages

- **`shipping-point.html`**: the first schema draft assumed a
  `shipping_points` table with a self-referencing `parent_id`. That doesn't
  match reality — "Shipping Point" isn't a stored entity, it's computed
  client-side (`buildShippingPoints()`) as one "main warehouse" per DC plus
  one per active Depot. The schema models `distribution_centers` + `depots`
  directly instead; `staging_bay_coverage.shipping_point_id` is a plain text
  column holding the same synthetic id the client generates
  (`sp-main-<dc id>` / `sp-depo-<depot id>`).
- **`app-monitoring.html`**: its driver roster references 6 DCs
  (Solo/Bandung/Bogor/Tasikmalaya/Semarang/Sukabumi) — only 2 of which
  overlapped with `shipping-point.html`'s 3 (Mataram/Bandung/Solo), and with
  a different per-driver DC assignment than the original seed.sql had
  guessed. `seed.sql` now adds the 4 missing DCs and maps every driver to
  match `app-monitoring.html`'s mock data exactly (verified via SQL join,
  row for row).
- **RLS policies were scoped to the wrong Postgres role.** ShipGo still uses
  its own PIN login (`middleware.js`), not Supabase Auth, so the browser's
  supabase-js client always connects as `anon` — never `authenticated`.
  Policies written `to authenticated` silently returned zero rows for every
  query instead of erroring. Fixed by re-scoping to `anon` (see
  `fix_rls_anon.sql` below). Confirmed via `curl` before/after: `200 OK []`
  → `200 OK [...]`.

All of `schema.sql` / `seed.sql` / the patch files have been verified
end-to-end against a local scratch Postgres before being handed over — table
creation, seed row counts, and query results were checked to match the
original mock data exactly, not just "runs without an error."

## If your project already ran the old schema.sql / seed.sql

Run these two patch files once, in your SQL Editor, in this order:

1. **`fix_rls_anon.sql`** — corrects the RLS policies (`authenticated` → `anon`).
2. **`patch_app_monitoring.sql`** — adds the 4 missing DCs, fixes each
   driver's `dc_id` to match `app-monitoring.html`, and backfills
   `device_version_history` (which the original `seed.sql` never populated).

A **fresh** project should just run `schema.sql` then `seed.sql` — both
already include these fixes.

## Local / deployed configuration

- Local testing: `SUPABASE_URL` / `SUPABASE_ANON_KEY` are already set in a
  gitignored `.env.local`.
- Deployed site: add the same two variables to the project's Environment
  Variables in Vercel, then redeploy:
  - `SUPABASE_URL` = `https://utjfmriqgcinrgqzyzci.supabase.co`
  - `SUPABASE_ANON_KEY` = your publishable key (the `sb_publishable_...` one)

## Later phases

- Replace the shared PIN login with real Supabase Auth (per-user sessions) —
  once that lands, tighten RLS policies from `anon` back to `authenticated`
  plus per-role checks against `profiles.role`.
- Add write UI for Distribution Centers / Depots / Staging Bays / Routes on
  `shipping-point.html` — today the only mutable thing there is coverage
  assignment; there's no Add/Edit/Delete for the rest yet.
- Add a way to add/remove drivers and devices on `app-monitoring.html` —
  today only editing an existing driver's Shipping Point and a device's App
  Version is wired.
