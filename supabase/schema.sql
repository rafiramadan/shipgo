-- ============================================================
-- ShipGo TMS — Supabase schema (Phase 1, revised)
-- Covers: user profiles (Supabase Auth), Distribution Center / Depot
-- master data, Staging Bay + route (kecamatan) coverage, Drivers,
-- and Device / App Monitoring data.
--
-- Revised from the original draft after reading shipping-point.html's
-- actual mock data: "Shipping Point" turned out to be a UI-only concept
-- computed client-side (buildShippingPoints() — one synthetic
-- "main warehouse" per DC, plus one per active Depot), not a stored
-- entity, so this schema models the two REAL tables (distribution
-- centers, depots) instead of a speculative shipping_points table.
--
-- Run this once in the Supabase SQL editor (Project -> SQL Editor -> New query),
-- or via `supabase db push` if you're using the Supabase CLI.
-- ============================================================

create extension if not exists "pgcrypto"; -- for gen_random_uuid()

-- ── PROFILES ── (one row per Supabase Auth user, app-specific fields)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null default 'admin', -- 'admin' | 'driver_coordinator' | 'bcr' | 'admin_kasir' | 'admin_logistik'
  employee_id text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Profiles are viewable by authenticated users"
  on public.profiles for select to authenticated using (true);

create policy "Users can update their own profile"
  on public.profiles for update to authenticated using (id = auth.uid());

-- Auto-create a profile row whenever someone signs up via Supabase Auth.
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email));
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── DISTRIBUTION CENTERS ── (DCS in shipping-point.html)
create table public.distribution_centers (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,       -- e.g. '1336' for [1336] PARAMA DC MATARAM
  name text not null,
  status text not null default 'active' check (status in ('active', 'inactive')),
  created_at timestamptz not null default now()
);

-- ── DEPOTS ── (DEPOS in shipping-point.html — cross-dock, fed by exactly one DC)
create table public.depots (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  dc_id uuid not null references public.distribution_centers(id) on delete cascade,
  status text not null default 'active' check (status in ('active', 'inactive')),
  created_at timestamptz not null default now()
);

-- ── STAGING BAYS ── (unit of coverage assignment; scoped to one DC)
create table public.staging_bays (
  id uuid primary key default gen_random_uuid(),
  dc_id uuid not null references public.distribution_centers(id) on delete cascade,
  name text not null,              -- e.g. 'Staging Bay A', or a single kecamatan name
  province text not null,
  city text not null,               -- KOTA/KABUPATEN — matches the UI's city filter
  created_at timestamptz not null default now()
);

-- ── ROUTES ── (kecamatan grouped into a Staging Bay — routes[] per bay in the mock data)
create table public.staging_bay_routes (
  id uuid primary key default gen_random_uuid(),
  staging_bay_id uuid not null references public.staging_bays(id) on delete cascade,
  name text not null,               -- kecamatan name
  postal_code text,
  lat double precision,
  lng double precision,
  created_at timestamptz not null default now()
);

-- ── COVERAGE ── (which Shipping Point owns a Staging Bay — Scenario 3 & 4: single owner)
-- There is no "shipping_points" table: a Shipping Point is either a DC's own
-- main warehouse or one of its Depots, exactly as buildShippingPoints()
-- computes client-side. shipping_point_id here stores that SAME synthetic id
-- ('sp-main-<dc id>' or 'sp-depo-<depot id>') as plain text so the client's
-- existing id scheme needs no translation layer — simpler than a polymorphic
-- FK for a prototype at this stage.
create table public.staging_bay_coverage (
  staging_bay_id uuid primary key references public.staging_bays(id) on delete cascade,
  shipping_point_id text,
  assigned_at timestamptz not null default now()
);

-- ── DRIVERS ──
create table public.drivers (
  id uuid primary key default gen_random_uuid(),
  employee_id text unique not null,
  full_name text not null,
  dc_id uuid references public.distribution_centers(id),
  created_at timestamptz not null default now()
);

-- ── DEVICES ── (App Monitoring / Driver App Version)
create table public.devices (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.drivers(id) on delete cascade,
  brand text,
  model text not null,
  manufacturer text,
  os text not null,
  sdk_int integer,
  app_version text not null,
  last_active_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.device_version_history (
  id uuid primary key default gen_random_uuid(),
  device_id uuid not null references public.devices(id) on delete cascade,
  version text not null,
  installed_at date not null,
  method text not null default 'Play Store'
);

-- ── Row Level Security ──
-- Prototype-stage policy: anyone holding the anon key can read/write this
-- master data. Scoped to the `anon` Postgres role (not `authenticated`)
-- because ShipGo still gates access with its own PIN login + JWT cookie
-- (middleware.js) rather than Supabase Auth — the browser's supabase-js
-- client is never actually signed in to Supabase, so it always connects as
-- `anon`. A policy written `to authenticated` would silently return zero
-- rows for every query instead of erroring, which is exactly what happened
-- here originally. Once real Supabase Auth replaces the PIN login (a later
-- phase — see supabase/README.md), tighten these to `to authenticated` and
-- per-role checks against `profiles.role`.
alter table public.distribution_centers enable row level security;
alter table public.depots enable row level security;
alter table public.staging_bays enable row level security;
alter table public.staging_bay_routes enable row level security;
alter table public.staging_bay_coverage enable row level security;
alter table public.drivers enable row level security;
alter table public.devices enable row level security;
alter table public.device_version_history enable row level security;

create policy "Anon read" on public.distribution_centers for select to anon using (true);
create policy "Anon read" on public.depots for select to anon using (true);
create policy "Anon read" on public.staging_bays for select to anon using (true);
create policy "Anon read" on public.staging_bay_routes for select to anon using (true);
create policy "Anon read" on public.staging_bay_coverage for select to anon using (true);
create policy "Anon read" on public.drivers for select to anon using (true);
create policy "Anon read" on public.devices for select to anon using (true);
create policy "Anon read" on public.device_version_history for select to anon using (true);

create policy "Anon write" on public.distribution_centers for all to anon using (true) with check (true);
create policy "Anon write" on public.depots for all to anon using (true) with check (true);
create policy "Anon write" on public.staging_bays for all to anon using (true) with check (true);
create policy "Anon write" on public.staging_bay_routes for all to anon using (true) with check (true);
create policy "Anon write" on public.staging_bay_coverage for all to anon using (true) with check (true);
create policy "Anon write" on public.drivers for all to anon using (true) with check (true);
create policy "Anon write" on public.devices for all to anon using (true) with check (true);
create policy "Anon write" on public.device_version_history for all to anon using (true) with check (true);
