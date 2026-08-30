-- ============================================================
-- ShipGo TMS — Fix: RLS policies were scoped to the wrong Postgres role
--
-- schema.sql originally wrote every policy as `to authenticated`. ShipGo
-- still gates page access with its own PIN login + JWT cookie
-- (middleware.js), not Supabase Auth, so the browser's supabase-js client
-- is never actually signed in to Supabase — it always connects as the
-- `anon` role. A policy scoped `to authenticated` silently returns ZERO
-- rows for every query instead of erroring (confirmed: GET
-- .../rest/v1/distribution_centers returned 200 OK with an empty array).
--
-- Run this ONCE against a project that already ran the original schema.sql
-- (i.e. your live project right now). A fresh project should just use the
-- corrected schema.sql instead — this file only exists to patch policies
-- on tables that already exist.
-- ============================================================

drop policy if exists "Authenticated read" on public.distribution_centers;
drop policy if exists "Authenticated read" on public.depots;
drop policy if exists "Authenticated read" on public.staging_bays;
drop policy if exists "Authenticated read" on public.staging_bay_routes;
drop policy if exists "Authenticated read" on public.staging_bay_coverage;
drop policy if exists "Authenticated read" on public.drivers;
drop policy if exists "Authenticated read" on public.devices;
drop policy if exists "Authenticated read" on public.device_version_history;

drop policy if exists "Authenticated write" on public.distribution_centers;
drop policy if exists "Authenticated write" on public.depots;
drop policy if exists "Authenticated write" on public.staging_bays;
drop policy if exists "Authenticated write" on public.staging_bay_routes;
drop policy if exists "Authenticated write" on public.staging_bay_coverage;
drop policy if exists "Authenticated write" on public.drivers;
drop policy if exists "Authenticated write" on public.devices;
drop policy if exists "Authenticated write" on public.device_version_history;

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
