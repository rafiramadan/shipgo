-- ============================================================
-- ShipGo TMS — Supabase schema (Phase 1)
-- Covers: user profiles (Supabase Auth), Shipping Point hierarchy,
-- Staging Bay coverage, Drivers, and Device / App Monitoring data.
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

-- ── SHIPPING POINTS ── (Distribution Center / Depot hierarchy, L1 -> L2)
create table public.shipping_points (
  id uuid primary key default gen_random_uuid(),
  code text unique,               -- e.g. '1309' for [1309] DC Solo
  name text not null,             -- e.g. 'DC Solo', 'Depo Klaten'
  type text not null check (type in ('distribution_center', 'depot')),
  parent_id uuid references public.shipping_points(id), -- a depot's main DC; null for a DC
  status text not null default 'active' check (status in ('active', 'inactive')),
  created_at timestamptz not null default now()
);

-- ── STAGING BAYS ── (grouped under one Distribution Center)
create table public.staging_bays (
  id uuid primary key default gen_random_uuid(),
  shipping_point_id uuid not null references public.shipping_points(id) on delete cascade,
  name text not null,             -- e.g. 'Staging Bay A'
  created_at timestamptz not null default now()
);

-- ── DISTRICTS mapped into a Staging Bay ── (route code + kecamatan)
create table public.staging_bay_districts (
  id uuid primary key default gen_random_uuid(),
  staging_bay_id uuid not null references public.staging_bays(id) on delete cascade,
  route_code text not null,
  kecamatan text not null,
  city text,
  postal_code text,
  latitude double precision,
  longitude double precision,
  created_at timestamptz not null default now()
);

-- ── COVERAGE ── (which Shipping Point currently owns/serves a Staging Bay)
create table public.staging_bay_coverage (
  staging_bay_id uuid primary key references public.staging_bays(id) on delete cascade,
  shipping_point_id uuid references public.shipping_points(id),
  assigned_at timestamptz not null default now()
);

-- ── DRIVERS ──
create table public.drivers (
  id uuid primary key default gen_random_uuid(),
  employee_id text unique not null,
  full_name text not null,
  shipping_point_id uuid references public.shipping_points(id),
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
-- Prototype-stage policy: any signed-in user can read and write master data.
-- Tighten this later per role (e.g. only BCR can write Shipping Points) once
-- the `profiles.role` values are actually enforced in the UI.
alter table public.shipping_points enable row level security;
alter table public.staging_bays enable row level security;
alter table public.staging_bay_districts enable row level security;
alter table public.staging_bay_coverage enable row level security;
alter table public.drivers enable row level security;
alter table public.devices enable row level security;
alter table public.device_version_history enable row level security;

create policy "Authenticated read" on public.shipping_points for select to authenticated using (true);
create policy "Authenticated read" on public.staging_bays for select to authenticated using (true);
create policy "Authenticated read" on public.staging_bay_districts for select to authenticated using (true);
create policy "Authenticated read" on public.staging_bay_coverage for select to authenticated using (true);
create policy "Authenticated read" on public.drivers for select to authenticated using (true);
create policy "Authenticated read" on public.devices for select to authenticated using (true);
create policy "Authenticated read" on public.device_version_history for select to authenticated using (true);

create policy "Authenticated write" on public.shipping_points for all to authenticated using (true) with check (true);
create policy "Authenticated write" on public.staging_bays for all to authenticated using (true) with check (true);
create policy "Authenticated write" on public.staging_bay_districts for all to authenticated using (true) with check (true);
create policy "Authenticated write" on public.staging_bay_coverage for all to authenticated using (true) with check (true);
create policy "Authenticated write" on public.drivers for all to authenticated using (true) with check (true);
create policy "Authenticated write" on public.devices for all to authenticated using (true) with check (true);
create policy "Authenticated write" on public.device_version_history for all to authenticated using (true) with check (true);
