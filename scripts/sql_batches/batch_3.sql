
WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+13177665164', 'Lauracarlton', 'badbaby_girl22@yhoo.com', s.id, '22289680',
    1, 'migration'::customer_source_enum,
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
SELECT c.id, c.home_store_id, 1, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289680'
FROM c WHERE 1 <> 0
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
    '+12602068648', 'Candice (B)', NULL, s.id, '22289681',
    415, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-03-03T11:12:00'::timestamptz
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
SELECT c.id, c.home_store_id, 165, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289681'
FROM c WHERE 165 <> 0
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
    '+12602136438', 'User 6438', NULL, s.id, '22289682',
    731, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-10-15T07:31:00'::timestamptz
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
SELECT c.id, c.home_store_id, 231, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289682'
FROM c WHERE 231 <> 0
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
    '+12604983874', 'Michaela', NULL, s.id, '22289683',
    716, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-12-12T15:22:00'::timestamptz
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
SELECT c.id, c.home_store_id, 216, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289683'
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
    '+12605157370', 'Shyra', 'tbth_jones@yahoo.com', s.id, '22289684',
    760, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-08-30T12:11:00'::timestamptz
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
SELECT c.id, c.home_store_id, 10, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289684'
FROM c WHERE 10 <> 0
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
    '+12602067987', 'Tia Ogunsusi', 'evalynogunsusi@gmail.com', s.id, '22289685',
    101, 'migration'::customer_source_enum,
    false, NULL,
    true, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-10T11:55:00'::timestamptz
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
SELECT c.id, c.home_store_id, 101, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289685'
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
    '+12602054405', 'Samantha', 'popplewellsamantha@gmail.com', s.id, '22289686',
    222, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-11T12:10:00'::timestamptz
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
SELECT c.id, c.home_store_id, 222, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289686'
FROM c WHERE 222 <> 0
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
    '+12602038427', 'User 8427', NULL, s.id, '22289687',
    95, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-10T12:46:00'::timestamptz
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
SELECT c.id, c.home_store_id, 95, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289687'
FROM c WHERE 95 <> 0
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
    '+12684459455', 'User 9455', NULL, s.id, '22289688',
    249, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-03-29T12:08:00'::timestamptz
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
SELECT c.id, c.home_store_id, 249, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289688'
FROM c WHERE 249 <> 0
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
    '+12602340282', 'User 0282', NULL, s.id, '22289689',
    67, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-07-24T10:01:00'::timestamptz
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
SELECT c.id, c.home_store_id, 67, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289689'
FROM c WHERE 67 <> 0
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
    '+15743342146', 'Taria', NULL, s.id, '22289690',
    100, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-05-13T15:45:00'::timestamptz
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
SELECT c.id, c.home_store_id, 100, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289690'
FROM c WHERE 100 <> 0
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
    '+12602056311', 'User 6311', NULL, s.id, '22289692',
    14, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-06-05T09:22:00'::timestamptz
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
SELECT c.id, c.home_store_id, 14, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289692'
FROM c WHERE 14 <> 0
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
    '+14043838639', 'User 8639', NULL, s.id, '22289693',
    46, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-06T11:26:00'::timestamptz
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
SELECT c.id, c.home_store_id, 46, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289693'
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
    '+12604450530', 'User 0530', NULL, s.id, '22289694',
    37, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-08T11:46:00'::timestamptz
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
SELECT c.id, c.home_store_id, 37, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289694'
FROM c WHERE 37 <> 0
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
    '+12602983879', 'User 0575', 'johsoh88@gmail.com', s.id, '22289695',
    2589, 'migration'::customer_source_enum,
    true, NULL,
    true, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-05-27T15:01:00'::timestamptz
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
SELECT c.id, c.home_store_id, 107, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289695'
FROM c WHERE 107 <> 0
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
    '+12602467114', 'User 7114', NULL, s.id, '22289696',
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289696'
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
    '+12607159922', 'User 9922', NULL, s.id, '22289697',
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289697'
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
    '+12602671002', 'User 1002', NULL, s.id, '22289698',
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289698'
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
    '+12604428587', 'Satarra Gibson', 'tarraloves3@yahoo.com', s.id, '22289699',
    2540, 'migration'::customer_source_enum,
    true, NULL,
    true, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-07-26T12:07:00'::timestamptz
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
SELECT c.id, c.home_store_id, 384, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289699'
FROM c WHERE 384 <> 0
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
    '+12602552301', 'User 2301', NULL, s.id, '22289700',
    794, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-08T10:55:00'::timestamptz
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
SELECT c.id, c.home_store_id, 294, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289700'
FROM c WHERE 294 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;
