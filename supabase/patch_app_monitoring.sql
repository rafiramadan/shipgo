-- ============================================================
-- ShipGo TMS — Patch: reconcile driver/DC data with app-monitoring.html
--
-- The original seed.sql mapped all 10 drivers onto shipping-point.html's
-- 3 DCs (Mataram/Bandung/Solo). app-monitoring.html's real mock data
-- actually references 6 DCs (Solo/Bandung/Bogor/Tasikmalaya/Semarang/
-- Sukabumi) with a different per-driver assignment. This patch adds the
-- 4 missing DCs, corrects each driver's dc_id to match app-monitoring.html
-- exactly, and adds device_version_history rows (a table the original
-- seed.sql never populated at all).
--
-- Safe to run once against a project that already ran the original
-- schema.sql + seed.sql (i.e. your live project right now). A fresh
-- project should just use the corrected seed.sql instead.
-- ============================================================

insert into public.distribution_centers (code, name, status) values
  ('1108', 'PARAMA DC BOGOR', 'active'),
  ('1112', 'PARAMA DC TASIKMALAYA', 'active'),
  ('1207', 'PARAMA DC SEMARANG', 'active'),
  ('1208', 'PARAMA DC SUKABUMI', 'active')
on conflict (code) do nothing;

update public.drivers d set dc_id = dc.id
from (values
  ('EMP1001', 'PARAMA DC SOLO'),
  ('EMP1002', 'PARAMA DC BANDUNG'),
  ('EMP1003', 'PARAMA DC BOGOR'),
  ('EMP1004', 'PARAMA DC TASIKMALAYA'),
  ('EMP1005', 'PARAMA DC SOLO'),
  ('EMP1006', 'PARAMA DC SEMARANG'),
  ('EMP1007', 'PARAMA DC BANDUNG'),
  ('EMP1008', 'PARAMA DC SUKABUMI'),
  ('EMP1009', 'PARAMA DC SOLO'),
  ('EMP1010', 'PARAMA DC BOGOR')
) as v(employee_id, dc_name)
join public.distribution_centers dc on dc.name = v.dc_name
where d.employee_id = v.employee_id;

insert into public.device_version_history (device_id, version, installed_at, method)
select dev.id, v.version, (now() - (v.days_ago || ' days')::interval)::date, v.method
from (values
  ('EMP1001', '3.2.0', 96, 'Play Store'), ('EMP1001', '3.4.0', 30, 'Play Store'),
  ('EMP1002', '3.2.0', 90, 'Play Store'), ('EMP1002', '3.4.0', 25, 'Play Store'),
  ('EMP1003', '3.1.0', 120, 'Play Store'), ('EMP1003', '3.3.0', 45, 'Play Store'),
  ('EMP1004', '2.8.0', 200, 'Manual APK'), ('EMP1004', '2.9.5', 110, 'Play Store'),
  ('EMP1005', '3.2.0', 88, 'Play Store'), ('EMP1005', '3.4.0', 28, 'Play Store'),
  ('EMP1006', '3.2.0', 80, 'Play Store'), ('EMP1006', '3.4.0', 20, 'Play Store'),
  ('EMP1007', '3.1.0', 100, 'Play Store'), ('EMP1007', '3.3.0', 40, 'Play Store'),
  ('EMP1008', '2.9.5', 150, 'Play Store'), ('EMP1008', '3.1.0', 60, 'Play Store'),
  ('EMP1009', '3.2.0', 92, 'Play Store'), ('EMP1009', '3.4.0', 32, 'Play Store'),
  ('EMP1010', '3.2.0', 85, 'Play Store'), ('EMP1010', '3.4.0', 22, 'Play Store')
) as v(employee_id, version, days_ago, method)
join public.drivers d on d.employee_id = v.employee_id
join public.devices dev on dev.driver_id = d.id
where not exists (
  select 1 from public.device_version_history h where h.device_id = dev.id
);
