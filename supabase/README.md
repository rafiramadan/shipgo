# ShipGo + Supabase — Setup Notes

Phase 1 covers: Auth (replacing the shared PIN) + master data currently
hardcoded in `shipping-point.html` and `app-monitoring.html` (Shipping Points,
Staging Bays, District coverage, Drivers, Devices).

Not yet modeled: Shipment Planning, Live/History Tracking, Feature Config,
Group/Role, User Management. These stay on their current mock data until a
later phase.

## 1. Create the project

1. Go to https://supabase.com and sign in (or create an account).
2. **New project** → give it a name (e.g. `shipgo-tms`), set a database
   password (save it somewhere safe — it's separate from any app login), pick
   the region closest to your users (e.g. Singapore), and create it.
3. Wait ~2 minutes for provisioning.

## 2. Get your API credentials

In the project, go to **Project Settings → API**. You'll need:

- **Project URL** — looks like `https://xxxxxxxx.supabase.co`
- **anon public key** — safe to embed in client-side code (protected by Row
  Level Security, not secrecy)
- **service_role key** — full-access, server-side only. **Never share this in
  chat or commit it to the repo** — it goes directly into Vercel's
  Environment Variables when we wire up the server-side auth code.

## 3. Run the schema + seed data

In the project, go to **SQL Editor → New query**:

1. Paste and run `schema.sql` first.
2. Paste and run `seed.sql` second.

This creates the tables and Row Level Security policies, and populates them
with the same DC Solo / Staging Bay A / driver roster data already shown in
the prototype, so nothing will look different at first glance — it'll just be
reading from a real database instead of a hardcoded array.

## 4. What happens next

Once you share the **Project URL** and **anon key** (both safe to paste here),
and add `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY`
directly to the project's Environment Variables in Vercel (not in chat), I'll:

- Replace the PIN login (`login.html`, `api/auth/*`, `middleware.js`) with
  Supabase Auth (email + password), issuing real per-user sessions instead of
  one shared identity.
- Point `shipping-point.html` and `app-monitoring.html` at the new tables via
  the Supabase JS client, instead of their in-page mock arrays.

That'll be tested against your real project before anything gets pushed —
auth code doesn't ship untested twice in one lifetime.
