
WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12607022460', 'Annalisa', NULL, s.id, '22289638',
    2478, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-07-07T06:57:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 228, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289638'
FROM c WHERE 228 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12602036759', 'Lasandra Jones', 'only1rolly@aol.com', s.id, '22289639',
    58, 'migration'::customer_source_enum,
    false, NULL,
    true, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-05-12T09:20:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 58, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289639'
FROM c WHERE 58 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12604026352', 'User 6352', NULL, s.id, '22289640',
    241, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2024-02-25T08:26:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 241, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289640'
FROM c WHERE 241 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12605159486', 'User 9486', NULL, s.id, '22289641',
    0, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-09-10T15:13:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289641'
FROM c WHERE 0 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12162069032', 'User 9032', NULL, s.id, '22289642',
    118, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-05-29T08:45:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 118, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289642'
FROM c WHERE 118 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12602062379', 'User 2379', NULL, s.id, '22289643',
    200, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-05-02T08:11:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 216, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289643'
FROM c WHERE 216 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12607021558', 'Alevtina Allie Snegirev', 'alliesnegirev@gmail.com', s.id, '22289644',
    0, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-09-10T15:13:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289644'
FROM c WHERE 0 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12604400566', 'User 0566', NULL, s.id, '22289645',
    39, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-10-24T09:03:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 39, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289645'
FROM c WHERE 39 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12606027551', 'User 7551', NULL, s.id, '22289646',
    1541, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-05-09T14:56:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 41, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289646'
FROM c WHERE 41 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12604094200', 'User 4200', NULL, s.id, '22289649',
    40, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-14T08:35:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 40, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289649'
FROM c WHERE 40 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12604381067', 'User 1067', NULL, s.id, '22289650',
    351, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-18T11:15:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 101, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289650'
FROM c WHERE 101 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12607556616', 'Kathy Moran', NULL, s.id, '22289651',
    82, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-14T07:20:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 82, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289651'
FROM c WHERE 82 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12607456554', 'Maria Paniagua', NULL, s.id, '22289652',
    35, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-12-20T13:46:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 56, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289652'
FROM c WHERE 56 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12602099692', 'User 9692', NULL, s.id, '22289653',
    46, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-14T07:56:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 46, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289653'
FROM c WHERE 46 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12603055393', 'User 5393', NULL, s.id, '22289654',
    334, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-05-01T11:51:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 84, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289654'
FROM c WHERE 84 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12607559599', 'User 9599', NULL, s.id, '22289655',
    145, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-11-14T10:57:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 145, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289655'
FROM c WHERE 145 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12605159586', 'User 9586', NULL, s.id, '22289656',
    33, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-14T08:07:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 33, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289656'
FROM c WHERE 33 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+13177536469', 'User 6469', NULL, s.id, '22289657',
    266, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-08T08:19:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 266, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289657'
FROM c WHERE 266 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12602474893', 'User 4893', NULL, s.id, '22289658',
    24, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2022-09-06T11:41:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 24, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289658'
FROM c WHERE 24 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12604109186', 'User 9186', NULL, s.id, '22289659',
    302, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-04-21T15:29:00'::timestamptz
  FROM s
  ON CONFLICT (legacy_tapmango_id) DO UPDATE SET
    phone = EXCLUDED.phone,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    home_store_id = EXCLUDED.home_store_id,
    lifetime_points_at_migration = EXCLUDED.lifetime_points_at_migration,
    updated_at = now()
  RETURNING id, home_store_id
)
INSERT INTO points_ledger (customer_id, store_id, delta, reason, ref_type, idempotency_key)
SELECT c.id, c.home_store_id, 52, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289659'
FROM c WHERE 52 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;
