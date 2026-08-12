
WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12482125315', 'User 5315', NULL, s.id, '22289660',
    133, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-12-10T14:00:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 133, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289660'
FROM c WHERE 133 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+18609443092', 'User 3092', NULL, s.id, '22289661',
    482, 'migration'::customer_source_enum,
    true, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-08-07T14:14:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 232, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289661'
FROM c WHERE 232 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12604478249', 'Priscilla', NULL, s.id, '22289662',
    0, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-13T14:38:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289662'
FROM c WHERE 0 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12607157405', 'User 7405', NULL, s.id, '22289663',
    22, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-24T06:08:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 22, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289663'
FROM c WHERE 22 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12607056006', 'User 6006', NULL, s.id, '22289664',
    0, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-13T13:56:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289664'
FROM c WHERE 0 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12607398960', 'User 8960', NULL, s.id, '22289665',
    308, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-02-14T08:07:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 58, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289665'
FROM c WHERE 58 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12604524462', 'User 4462', NULL, s.id, '22289666',
    120, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-08-24T10:08:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 120, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289666'
FROM c WHERE 120 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12603871285', 'User 1285', NULL, s.id, '22289667',
    0, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-13T10:35:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289667'
FROM c WHERE 0 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+19375973408', 'User 3408', NULL, s.id, '22289668',
    30, 'migration'::customer_source_enum,
    false, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-04-14T09:55:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 30, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289668'
FROM c WHERE 30 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, email_subscribed, registered_at, last_seen_at
  )
  SELECT '+12602551761', 'User 1761', NULL, s.id, '22289669',
    651, 'migration'::customer_source_enum,
    true, false,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-27T11:14:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone, name = EXCLUDED.name, email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 151, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289669'
FROM c WHERE 151 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;
