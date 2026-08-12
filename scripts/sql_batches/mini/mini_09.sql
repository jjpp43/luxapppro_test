
WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12602064017', 'User 4017', NULL, s.id, '22289712',
    42, 'migration'::customer_source_enum,
    true, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-05T08:45:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 42, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289712'
FROM c WHERE 42 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+15743006399', 'User 6399', NULL, s.id, '22289713',
    79, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-12-06T13:16:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 79, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289713'
FROM c WHERE 79 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12602346003', 'User 6003', NULL, s.id, '22289714',
    1836, 'migration'::customer_source_enum,
    true, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-07-11T15:05:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 67, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289714'
FROM c WHERE 67 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12607399228', 'User 9228', NULL, s.id, '22289715',
    0, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-09-10T15:13:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289715'
FROM c WHERE 0 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12604471731', 'User 1731', NULL, s.id, '22289716',
    0, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-06-26T10:25:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289716'
FROM c WHERE 0 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12603858517', 'User 8517', NULL, s.id, '22289717',
    9, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-04T14:47:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 9, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289717'
FROM c WHERE 9 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+13172008454', 'User 8454', NULL, s.id, '22289718',
    1647, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-05-24T08:51:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 222, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289718'
FROM c WHERE 222 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12607559371', 'Preonda', NULL, s.id, '22289720',
    79, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-08-08T13:38:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 79, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289720'
FROM c WHERE 79 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+15748474711', 'User 4711', NULL, s.id, '22289721',
    156, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-03-10T10:20:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 156, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289721'
FROM c WHERE 156 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12404861198', 'User 1198', NULL, s.id, '22289722',
    1121, 'migration'::customer_source_enum,
    true, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-07-02T15:43:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 164, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289722'
FROM c WHERE 164 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;
