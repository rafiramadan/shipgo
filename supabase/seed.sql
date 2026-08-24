-- ============================================================
-- ShipGo TMS — Seed data (Phase 1)
-- Mirrors the mock data currently hardcoded in shipping-point.html
-- and app-monitoring.html, so the app looks the same once it reads
-- from Supabase instead of from in-page JS arrays.
--
-- Run this AFTER schema.sql, in the Supabase SQL editor.
-- ============================================================

-- ── Distribution Centers ──
insert into public.shipping_points (code, name, type) values
  ('1309', 'DC Solo', 'distribution_center'),
  (null, 'DC Bandung', 'distribution_center'),
  (null, 'DC Bogor', 'distribution_center'),
  (null, 'DC Tasikmalaya', 'distribution_center'),
  (null, 'DC Semarang', 'distribution_center'),
  (null, 'DC Sukabumi', 'distribution_center'),
  (null, 'DC Yogyakarta', 'distribution_center'),
  (null, 'Kota Serang', 'distribution_center'),
  (null, 'Kabupaten Serang', 'distribution_center');

-- ── Depots (Cross-Dock), attached to their main DC ──
insert into public.shipping_points (name, type, parent_id)
select 'Depo Klaten', 'depot', id from public.shipping_points where name = 'DC Solo';

insert into public.shipping_points (name, type, parent_id)
select 'Depo Purwosari', 'depot', id from public.shipping_points where name = 'DC Solo';

-- ── Staging Bays A–F under DC Solo ──
insert into public.staging_bays (shipping_point_id, name)
select id, bay_name
from public.shipping_points, unnest(array['Staging Bay A','Staging Bay B','Staging Bay C','Staging Bay D','Staging Bay E','Staging Bay F']) as bay_name
where name = 'DC Solo';

-- ── Districts for Staging Bay A (DC Solo) ──
insert into public.staging_bay_districts (staging_bay_id, route_code, kecamatan, city, postal_code, latitude, longitude)
select sb.id, d.route_code, d.kecamatan, 'Kota Surakarta', d.postal_code, d.lat, d.lng
from public.staging_bays sb
join public.shipping_points sp on sp.id = sb.shipping_point_id and sp.name = 'DC Solo'
join (values
  ('L00127', 'Banjarsari', '57137', -7.5455, 110.8241),
  ('L00143', 'Jebres',     '57126', -7.5590, 110.8390),
  ('L00234', 'Laweyan',    '57142', -7.5680, 110.7990),
  ('L00242', 'Serengan',   '57155', -7.5760, 110.8210),
  ('L00156', 'Pasar Kliwon', '57118', -7.5720, 110.8330)
) as d(route_code, kecamatan, postal_code, lat, lng) on true
where sb.name = 'Staging Bay A';

-- ── Coverage: Staging Bay A is currently owned/served by DC Solo ──
insert into public.staging_bay_coverage (staging_bay_id, shipping_point_id)
select sb.id, sp.id
from public.staging_bays sb
join public.shipping_points sp on sp.name = 'DC Solo'
where sb.name = 'Staging Bay A';

-- ── Drivers (roster reused across App Monitoring / Feature Config) ──
insert into public.drivers (employee_id, full_name, shipping_point_id)
select v.employee_id, v.full_name, sp.id
from (values
  ('EMP1001', 'Citra Mulyono',           'DC Solo'),
  ('EMP1002', 'M. Fadhli Salam',         'DC Bandung'),
  ('EMP1003', 'M. Iqbal Kurniawan',      'DC Bogor'),
  ('EMP1004', 'Tri Febrianto',           'DC Tasikmalaya'),
  ('EMP1005', 'Farraz Nanang Fauzan',    'DC Solo'),
  ('EMP1006', 'Alamsyah Satrio Aji',     'DC Semarang'),
  ('EMP1007', 'Abdullah Harmaen',        'DC Bandung'),
  ('EMP1008', 'Tio Sugiatna',            'DC Sukabumi'),
  ('EMP1009', 'Wahono Prasetyo',         'DC Solo'),
  ('EMP1010', 'Asep Kurnia',             'DC Bogor')
) as v(employee_id, full_name, dc_name)
join public.shipping_points sp on sp.name = v.dc_name;

-- ── Devices (one per driver, matching Version Monitoring's current mock) ──
insert into public.devices (driver_id, brand, model, manufacturer, os, sdk_int, app_version, last_active_at)
select d.id, v.brand, v.model, v.manufacturer, v.os, v.sdk_int, v.app_version, now() - (v.days_ago || ' days')::interval
from (values
  ('EMP1001', 'Samsung', 'Samsung SM-S937B',      'Samsung', 'Android 16', 36, '3.4.0', 0),
  ('EMP1002', 'Xiaomi',  'Xiaomi Redmi Note 12',  'Xiaomi',  'Android 13', 33, '3.4.0', 1),
  ('EMP1003', 'OPPO',    'OPPO A57',              'OPPO',    'Android 12', 31, '3.3.0', 2),
  ('EMP1004', 'vivo',    'Vivo Y22',              'vivo',    'Android 12', 31, '2.9.5', 15),
  ('EMP1005', 'realme',  'Realme C35',            'realme',  'Android 13', 33, '3.4.0', 0),
  ('EMP1006', 'Samsung', 'Samsung Galaxy A34',    'Samsung', 'Android 14', 34, '3.4.0', 3),
  ('EMP1007', 'Infinix', 'Infinix Hot 30',        'Infinix', 'Android 13', 33, '3.3.0', 5),
  ('EMP1008', 'itel',    'itel A60s',             'itel',    'Android 12', 31, '3.1.0', 9),
  ('EMP1009', 'Xiaomi',  'Xiaomi Redmi 10',       'Xiaomi',  'Android 11', 30, '3.4.0', 1),
  ('EMP1010', 'OPPO',    'OPPO A17',              'OPPO',    'Android 12', 31, '3.4.0', 2)
) as v(employee_id, brand, model, manufacturer, os, sdk_int, app_version, days_ago)
join public.drivers d on d.employee_id = v.employee_id;
