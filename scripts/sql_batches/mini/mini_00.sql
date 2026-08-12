
WITH s AS (SELECT id FROM stores WHERE name = 'Hairway 2 Heaven'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+15551234567', 'John Smith', 'applereview@tapmango.com', s.id, '22217907',
    0, 'migration'::customer_source_enum,
    false, false,
    '2021-09-06T09:16:00'::timestamptz,
    '2026-05-06T15:44:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22217907'
FROM c WHERE 0 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Lux Beauty Supply - West Sahara Avenue'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+16168816241', 'Customer', NULL, s.id, '22280453',
    527, 'migration'::customer_source_enum,
    true, false,
    '2021-09-10T06:47:00'::timestamptz,
    '2026-04-12T09:21:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 36, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22280453'
FROM c WHERE 36 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Lux Beauty Supply - West Sahara Avenue'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12312886746', 'Customer', NULL, s.id, '22280470',
    788, 'migration'::customer_source_enum,
    true, false,
    '2021-09-10T06:50:00'::timestamptz,
    '2026-07-08T17:59:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 284, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22280470'
FROM c WHERE 284 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12604520864', 'Only use mimi (B)Mimi Stylist', 'sunasiadejavu1996@gmail.com', s.id, '22280493',
    12816, 'migration'::customer_source_enum,
    true, false,
    '2021-09-10T06:54:00'::timestamptz,
    '2026-08-09T09:56:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 242, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22280493'
FROM c WHERE 242 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12602552949', 'User 2949', NULL, s.id, '22289618',
    36, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2024-11-02T19:19:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 36, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289618'
FROM c WHERE 36 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12193023459', 'User 3459', NULL, s.id, '22289619',
    20, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2022-04-01T19:16:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 44, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289619'
FROM c WHERE 44 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+16177518096', 'User 8096', NULL, s.id, '22289620',
    77, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-07-15T06:40:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 77, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289620'
FROM c WHERE 77 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12605570123', 'User 0123', NULL, s.id, '22289621',
    64, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2024-04-16T14:45:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 64, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289621'
FROM c WHERE 64 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12604428964', 'User 8964', NULL, s.id, '22289622',
    128, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2022-05-28T14:46:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 128, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289622'
FROM c WHERE 128 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12603876530', 'User 6530', NULL, s.id, '22289624',
    36, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-09-20T13:20:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 36, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289624'
FROM c WHERE 36 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;
