# ShipGo + Supabase — Setup Notes

**Project:** `utjfmriqgcinrgqzyzci` (https://supabase.com/dashboard/project/utjfmriqgcinrgqzyzci)
**Status:** Connected — `shipping-point.html` is wired to read/write Supabase.
Tables don't exist in the project yet (see "Next step" below); until you run
`schema.sql` + `seed.sql`, the page automatically falls back to its built-in
demo data, so nothing is broken in the meantime.

Phase 1 covers: master data currently hardcoded in `shipping-point.html`
(Distribution Centers, Depots, Staging Bays, District/route coverage) plus
Drivers/Devices (used by `app-monitoring.html`, not yet wired — see below).

Not yet modeled or wired: Auth (still the shared PIN), Shipment Planning,
Live/History Tracking, Feature Config, Group/Role, User Management,
`app-monitoring.html` itself. These stay on mock data until a later phase.

## How the connection works

- **`api/config.js`** — a tiny serverless endpoint that hands the browser
  `SUPABASE_URL` / `SUPABASE_ANON_KEY` from Vercel's Environment Variables.
  Both values are safe to expose client-side (Supabase's anon/publishable key
  is designed for this — access is enforced by the RLS policies below, not by
  keeping the key secret).
- **`supabase-client.js`** — shared helper, fetches `/api/config` once and
  creates the `supabase-js` client. Resolves to `null` if the env vars aren't
  set, which pages treat as "fall back to demo data" rather than an error.
- **`shipping-point.html`** — on load, fetches Distribution Centers, Depots,
  Staging Bays, Routes, and Coverage from Supabase and reshapes them into the
  exact same in-memory shape the page always used, so every render function
  is unchanged. If Supabase isn't configured (or a fetch fails), it falls back
  to the original hardcoded `MOCK_*` arrays instead of breaking.
- The **one real write** this page has — assigning/unassigning a Staging
  Bay's owning Shipping Point (`setBayOwner`) — now upserts/deletes a row in
  `staging_bay_coverage` instead of mutating an in-memory object, with the
  same "must unassign before reassigning" rule enforced before the write.

## Schema note — corrected from the original draft

The first version of `schema.sql` assumed a `shipping_points` table with a
self-referencing `parent_id`. After actually reading `shipping-point.html`'s
mock data, that turned out not to match reality: a "Shipping Point" isn't a
stored entity at all — it's computed client-side (`buildShippingPoints()`) as
one "main warehouse" per Distribution Center plus one per active Depot. The
schema now models the two real tables instead (`distribution_centers`,
`depots`), and `staging_bay_coverage.shipping_point_id` is a plain text
column holding the same synthetic id the client already generates
(`sp-main-<dc id>` / `sp-depo-<depot id>`) — simpler than a polymorphic FK for
a prototype at this stage. `schema.sql` and `seed.sql` have both been
verified end-to-end against a local scratch Postgres (tables create cleanly,
seed inserts the expected row counts, and a coverage join reproduces the
original mock data's assignments exactly, including the two bays left
intentionally unassigned).

## Next step (the one thing I can't do for you)

I don't have SQL Editor access to your project — I'm not logged into your
Supabase account, and your anon/publishable key can only read/write rows, not
create tables. Please run these two files yourself, in order:

1. Open **SQL Editor → New query** in your project.
2. Paste and run `supabase/schema.sql`.
3. Paste and run `supabase/seed.sql`.

Once that's done, reload `shipping-point.html` — it'll pick up the real data
automatically (nothing else to configure locally; I've already set
`SUPABASE_URL` / `SUPABASE_ANON_KEY` in a gitignored `.env.local` for local
testing). For the **deployed** site, add the same two variables to the
project's Environment Variables in Vercel:

- `SUPABASE_URL` = `https://utjfmriqgcinrgqzyzci.supabase.co`
- `SUPABASE_ANON_KEY` = your publishable key (the `sb_publishable_...` one)

## Later phases

- Wire `app-monitoring.html` to `drivers` / `devices` the same way.
- Replace the shared PIN login with real Supabase Auth (per-user sessions).
- Add write UI for Distribution Centers / Depots / Staging Bays / Routes —
  today the only mutable thing on `shipping-point.html` is coverage
  assignment; there's no Add/Edit/Delete for the rest yet.
