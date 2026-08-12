
WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12603480234', 'Victoria', NULL, s.id, '22289670',
    350, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-07-18T12:48:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 100, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289670'
FROM c WHERE 100 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12607402158', 'User 2158', NULL, s.id, '22289671',
    21, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-10T08:03:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 21, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289671'
FROM c WHERE 21 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12604490967', 'User 0967', NULL, s.id, '22289672',
    68, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-11T08:44:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 68, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289672'
FROM c WHERE 68 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12602579843', 'User 9843', NULL, s.id, '22289673',
    13, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-09T13:20:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 13, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289673'
FROM c WHERE 13 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12603852539', 'Mechel Minton', NULL, s.id, '22289674',
    247, 'migration'::customer_source_enum,
    true, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-05T13:27:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 247, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289674'
FROM c WHERE 247 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12602061334', 'User 1334', 'shaikirasimon12@gmail.com', s.id, '22289675',
    648, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-06T06:09:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 148, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289675'
FROM c WHERE 148 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12605793643', 'User 3643', NULL, s.id, '22289676',
    99, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-03-20T15:35:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 99, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289676'
FROM c WHERE 99 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+14849085676', 'User 5676', NULL, s.id, '22289677',
    51, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-09T12:26:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 51, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289677'
FROM c WHERE 51 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+15137802216', 'User 2216', NULL, s.id, '22289678',
    191, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-01-03T06:28:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 191, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289678'
FROM c WHERE 191 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12604182376', 'User 2376', NULL, s.id, '22289679',
    125, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-12-23T13:03:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 125, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289679'
FROM c WHERE 125 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;
