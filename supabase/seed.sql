-- ============================================================
-- ShipGo TMS — Seed data (Phase 1, revised)
-- Mirrors the ACTUAL mock data hardcoded in shipping-point.html
-- (the DCS / DEPOS / STAGING_BAYS / COVERAGE consts), so the app looks
-- identical once it reads from Supabase instead of those in-page arrays.
--
-- Run this AFTER schema.sql, in the Supabase SQL editor.
-- ============================================================

-- ── Distribution Centers ── (fixed ids so later inserts can reference them literally)
insert into public.distribution_centers (id, code, name, status) values
  ('11111111-1111-1111-1111-111111111111', '1336', 'PARAMA DC MATARAM', 'active'),
  ('22222222-2222-2222-2222-222222222222', '1204', 'PARAMA DC BANDUNG', 'active'),
  ('33333333-3333-3333-3333-333333333333', '1105', 'PARAMA DC SOLO', 'active');

-- ── Depots ── (each fed by exactly one DC)
insert into public.depots (id, name, dc_id, status) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Depo Prabumulih 01', '11111111-1111-1111-1111-111111111111', 'active'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Depo Sukabumi', '22222222-2222-2222-2222-222222222222', 'active');

-- ── Staging Bays — DC Mataram (single-route each, matches the legacy per-kecamatan platform) ──
insert into public.staging_bays (id, dc_id, name, province, city) values
  ('c0000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Cipocok Jaya', 'Banten', 'KOTA SERANG'),
  ('c0000000-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'Curug',        'Banten', 'KOTA SERANG'),
  ('c0000000-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'Kasemen',      'Banten', 'KOTA SERANG'),
  ('c0000000-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', 'Serang',       'Banten', 'KOTA SERANG'),
  ('c0000000-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', 'Taktakan',     'Banten', 'KOTA SERANG'),
  ('c0000000-0000-0000-0000-000000000006', '11111111-1111-1111-1111-111111111111', 'Walantaka',    'Banten', 'KOTA SERANG'),
  ('c0000000-0000-0000-0000-000000000007', '11111111-1111-1111-1111-111111111111', 'Anyar',        'Banten', 'KABUPATEN SERANG'),
  ('c0000000-0000-0000-0000-000000000008', '11111111-1111-1111-1111-111111111111', 'Bandung',      'Banten', 'KABUPATEN SERANG'),
  ('c0000000-0000-0000-0000-000000000009', '11111111-1111-1111-1111-111111111111', 'Ciruas',       'Banten', 'KABUPATEN SERANG'),
  ('c0000000-0000-0000-0000-00000000000a', '11111111-1111-1111-1111-111111111111', 'Kragilan',     'Banten', 'KABUPATEN SERANG');

-- ── Staging Bays — DC Bandung (multi-route groupings, the target staging-bay concept) ──
insert into public.staging_bays (id, dc_id, name, province, city) values
  ('d0000000-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', 'Staging Bay A', 'Jawa Barat', 'KOTA BANDUNG'),
  ('d0000000-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'Staging Bay B', 'Jawa Barat', 'KOTA BANDUNG'),
  ('d0000000-0000-0000-0000-000000000003', '22222222-2222-2222-2222-222222222222', 'Staging Bay C', 'Jawa Barat', 'KOTA BANDUNG');

-- ── Routes (kecamatan) — DC Mataram bays: one route per bay ──
insert into public.staging_bay_routes (staging_bay_id, name, postal_code, lat, lng) values
  ('c0000000-0000-0000-0000-000000000001', 'Cipocok Jaya', '42116', -6.1102, 106.1660),
  ('c0000000-0000-0000-0000-000000000002', 'Curug',        '42171', -6.0651, 106.0938),
  ('c0000000-0000-0000-0000-000000000003', 'Kasemen',      '42191', -6.0778, 106.1479),
  ('c0000000-0000-0000-0000-000000000004', 'Serang',       '42111', -6.1149, 106.1503),
  ('c0000000-0000-0000-0000-000000000005', 'Taktakan',     '42162', -6.1256, 106.1211),
  ('c0000000-0000-0000-0000-000000000006', 'Walantaka',    '42183', -6.1584, 106.1868),
  ('c0000000-0000-0000-0000-000000000007', 'Anyar',        '42466', -6.0733, 105.9214),
  ('c0000000-0000-0000-0000-000000000008', 'Bandung',      '42177', -6.2350, 106.1050),
  ('c0000000-0000-0000-0000-000000000009', 'Ciruas',       '42182', -6.0658, 106.1108),
  ('c0000000-0000-0000-0000-00000000000a', 'Kragilan',     '42184', -6.0234, 106.1934);

-- ── Routes — DC Bandung bays: 3 kecamatan each ──
insert into public.staging_bay_routes (staging_bay_id, name, postal_code, lat, lng) values
  ('d0000000-0000-0000-0000-000000000001', 'Coblong',       '40132', -6.8915, 107.6107),
  ('d0000000-0000-0000-0000-000000000001', 'Sukajadi',      '40164', -6.8894, 107.5924),
  ('d0000000-0000-0000-0000-000000000001', 'Cidadap',       '40142', -6.8677, 107.5987),
  ('d0000000-0000-0000-0000-000000000002', 'Bandung Wetan', '40114', -6.9042, 107.6186),
  ('d0000000-0000-0000-0000-000000000002', 'Sumur Bandung', '40111', -6.9147, 107.6098),
  ('d0000000-0000-0000-0000-000000000002', 'Batununggal',   '40272', -6.9382, 107.6339),
  ('d0000000-0000-0000-0000-000000000003', 'Kiaracondong',  '40281', -6.9280, 107.6489),
  ('d0000000-0000-0000-0000-000000000003', 'Antapani',      '40291', -6.9156, 107.6697),
  ('d0000000-0000-0000-0000-000000000003', 'Arcamanik',     '40293', -6.9089, 107.6819);

-- ── Coverage assignment — matches COVERAGE in shipping-point.html exactly ──
-- shipping_point_id follows the client's own synthetic id scheme:
-- 'sp-main-<dc id>' for a DC's main warehouse, 'sp-depo-<depot id>' for a depot.
insert into public.staging_bay_coverage (staging_bay_id, shipping_point_id) values
  ('c0000000-0000-0000-0000-000000000001', 'sp-main-11111111-1111-1111-1111-111111111111'),
  ('c0000000-0000-0000-0000-000000000002', 'sp-main-11111111-1111-1111-1111-111111111111'),
  ('c0000000-0000-0000-0000-000000000003', 'sp-depo-aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  ('c0000000-0000-0000-0000-000000000004', 'sp-main-11111111-1111-1111-1111-111111111111'),
  ('c0000000-0000-0000-0000-000000000005', 'sp-main-11111111-1111-1111-1111-111111111111'),
  ('c0000000-0000-0000-0000-000000000006', 'sp-main-11111111-1111-1111-1111-111111111111'),
  ('c0000000-0000-0000-0000-000000000007', 'sp-main-11111111-1111-1111-1111-111111111111'),
  ('c0000000-0000-0000-0000-000000000008', 'sp-main-11111111-1111-1111-1111-111111111111'),
  -- Ciruas / Kragilan intentionally left unassigned — demonstrates the "belum ada coverage" state
  ('d0000000-0000-0000-0000-000000000001', 'sp-main-22222222-2222-2222-2222-222222222222'),
  ('d0000000-0000-0000-0000-000000000002', 'sp-depo-bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  ('d0000000-0000-0000-0000-000000000003', 'sp-depo-bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');

-- ── Drivers (roster reused across App Monitoring / Feature Config) ──
insert into public.drivers (employee_id, full_name, dc_id)
select v.employee_id, v.full_name, dc.id
from (values
  ('EMP1001', 'Citra Mulyono',           'PARAMA DC MATARAM'),
  ('EMP1002', 'M. Fadhli Salam',         'PARAMA DC BANDUNG'),
  ('EMP1003', 'M. Iqbal Kurniawan',      'PARAMA DC SOLO'),
  ('EMP1004', 'Tri Febrianto',           'PARAMA DC MATARAM'),
  ('EMP1005', 'Farraz Nanang Fauzan',    'PARAMA DC BANDUNG'),
  ('EMP1006', 'Alamsyah Satrio Aji',     'PARAMA DC SOLO'),
  ('EMP1007', 'Abdullah Harmaen',        'PARAMA DC MATARAM'),
  ('EMP1008', 'Tio Sugiatna',            'PARAMA DC BANDUNG'),
  ('EMP1009', 'Wahono Prasetyo',         'PARAMA DC SOLO'),
  ('EMP1010', 'Asep Kurnia',             'PARAMA DC MATARAM')
) as v(employee_id, full_name, dc_name)
join public.distribution_centers dc on dc.name = v.dc_name;

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
