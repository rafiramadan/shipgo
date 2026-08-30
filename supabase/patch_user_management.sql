-- ============================================================
-- ShipGo TMS — Patch: add App Users + full DC master list
--
-- Purely additive (unlike the earlier RLS/app-monitoring patches, nothing
-- here needed correcting) — creates app_users + user_locations (new tables,
-- not in the original schema.sql your project already ran), adds the 27
-- Distribution Centers that only user-management.html's LOCATION_NAMES had
-- (the other 7 already exist from earlier phases), and seeds the 4 users
-- from user-management.html's mock data with their real Location Scope.
--
-- Safe to run once against a project that already ran the original
-- schema.sql + seed.sql (i.e. your live project right now). A fresh project
-- should just use the corrected schema.sql + seed.sql instead.
-- ============================================================

create table if not exists public.app_users (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  employee_id text unique not null,
  email text unique not null,
  phone text,
  role text not null check (role in ('Super Admin','Dispatcher','Fleet Viewer','Auditor')),
  status text not null default 'active' check (status in ('active','inactive')),
  updated_at date not null default current_date
);

create table if not exists public.user_locations (
  user_id uuid not null references public.app_users(id) on delete cascade,
  dc_id uuid not null references public.distribution_centers(id) on delete cascade,
  primary key (user_id, dc_id)
);

alter table public.app_users enable row level security;
alter table public.user_locations enable row level security;

drop policy if exists "Anon read" on public.app_users;
drop policy if exists "Anon write" on public.app_users;
drop policy if exists "Anon read" on public.user_locations;
drop policy if exists "Anon write" on public.user_locations;

create policy "Anon read" on public.app_users for select to anon using (true);
create policy "Anon write" on public.app_users for all to anon using (true) with check (true);
create policy "Anon read" on public.user_locations for select to anon using (true);
create policy "Anon write" on public.user_locations for all to anon using (true) with check (true);

insert into public.distribution_centers (code, name, status) values
  ('1401', 'DC Aceh', 'active'),
  ('1402', 'DC Ambon', 'active'),
  ('1403', 'DC Bali', 'active'),
  ('1404', 'DC Bangka', 'active'),
  ('1405', 'DC Banten', 'active'),
  ('1406', 'DC Bengkulu', 'active'),
  ('1407', 'DC Bukittinggi', 'active'),
  ('1408', 'DC Jambi', 'active'),
  ('1409', 'DC Kendari', 'active'),
  ('1410', 'DC Lampung', 'active'),
  ('1411', 'DC Manado', 'active'),
  ('1412', 'DC Palangkaraya', 'active'),
  ('1413', 'DC Palu', 'active'),
  ('1414', 'DC Pontianak', 'active'),
  ('1415', 'DC Purwokerto', 'active'),
  ('1416', 'DC Rantau Prapat', 'active'),
  ('1417', 'DC Samarinda', 'active'),
  ('1418', 'DC Surabaya', 'active'),
  ('1419', 'DC Tanjung Pinang', 'active'),
  ('1420', 'DC Banjarmasin', 'active'),
  ('1421', 'DC Cirebon', 'active'),
  ('1422', 'DC Jember', 'active'),
  ('1423', 'DC Kediri', 'active'),
  ('1424', 'DC Makassar', 'active'),
  ('1425', 'DC Medan', 'active'),
  ('1426', 'DC Palembang', 'active'),
  ('1427', 'DC Pekanbaru', 'active')
on conflict (code) do nothing;

insert into public.app_users (id, name, employee_id, email, phone, role, status, updated_at) values
  ('c1111111-1111-1111-1111-111111111111', 'Rafi Ramadani', 'EMP0001', 'dispatcher@shipgo.id', '+6281234567890', 'Dispatcher', 'active', '2026-07-01'),
  ('c2222222-2222-2222-2222-222222222222', 'Admin ShipGo', 'EMP0002', 'admin@shipgo.id', null, 'Super Admin', 'active', '2026-07-03'),
  ('c3333333-3333-3333-3333-333333333333', 'Siti Aminah', 'EMP0003', 'siti.aminah@shipgo.id', '+6281298765432', 'Fleet Viewer', 'active', '2026-06-20'),
  ('c4444444-4444-4444-4444-444444444444', 'Budi Santoso', 'EMP0004', 'budi.santoso@shipgo.id', null, 'Auditor', 'inactive', '2026-05-10')
on conflict (employee_id) do nothing;

insert into public.user_locations (user_id, dc_id)
select 'c1111111-1111-1111-1111-111111111111'::uuid, id from public.distribution_centers where name in ('PARAMA DC SOLO', 'PARAMA DC SEMARANG', 'DC Surabaya')
union all
select 'c3333333-3333-3333-3333-333333333333'::uuid, id from public.distribution_centers where name = 'PARAMA DC BANDUNG'
union all
select 'c2222222-2222-2222-2222-222222222222'::uuid, id from public.distribution_centers
union all
select 'c4444444-4444-4444-4444-444444444444'::uuid, id from public.distribution_centers
on conflict do nothing;
