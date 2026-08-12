
WITH s AS (SELECT id FROM stores WHERE name = 'Hairway 2 Heaven'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+15551234567', 'John Smith', 'applereview@tapmango.com', s.id, '22217907',
    0, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-06T09:16:00'::timestamptz,
    '2026-05-06T15:44:00'::timestamptz
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22217907'
FROM c WHERE 0 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Lux Beauty Supply - West Sahara Avenue'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+16168816241', 'Customer', NULL, s.id, '22280453',
    527, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T06:47:00'::timestamptz,
    '2026-04-12T09:21:00'::timestamptz
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
SELECT c.id, c.home_store_id, 36, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22280453'
FROM c WHERE 36 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;


WITH s AS (SELECT id FROM stores WHERE name = 'Lux Beauty Supply - West Sahara Avenue'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12312886746', 'Customer', NULL, s.id, '22280470',
    788, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T06:50:00'::timestamptz,
    '2026-07-08T17:59:00'::timestamptz
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
SELECT c.id, c.home_store_id, 284, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22280470'
FROM c WHERE 284 <> 0
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
    '+12604520864', 'Only use mimi (B)Mimi Stylist', 'sunasiadejavu1996@gmail.com', s.id, '22280493',
    12816, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T06:54:00'::timestamptz,
    '2026-08-09T09:56:00'::timestamptz
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
SELECT c.id, c.home_store_id, 242, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22280493'
FROM c WHERE 242 <> 0
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
    '+12602552949', 'User 2949', NULL, s.id, '22289618',
    36, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2024-11-02T19:19:00'::timestamptz
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
SELECT c.id, c.home_store_id, 36, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289618'
FROM c WHERE 36 <> 0
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
    '+12193023459', 'User 3459', NULL, s.id, '22289619',
    20, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2022-04-01T19:16:00'::timestamptz
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
SELECT c.id, c.home_store_id, 44, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289619'
FROM c WHERE 44 <> 0
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
    '+16177518096', 'User 8096', NULL, s.id, '22289620',
    77, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-07-15T06:40:00'::timestamptz
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
SELECT c.id, c.home_store_id, 77, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289620'
FROM c WHERE 77 <> 0
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
    '+12605570123', 'User 0123', NULL, s.id, '22289621',
    64, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2024-04-16T14:45:00'::timestamptz
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
SELECT c.id, c.home_store_id, 64, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289621'
FROM c WHERE 64 <> 0
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
    '+12604428964', 'User 8964', NULL, s.id, '22289622',
    128, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2022-05-28T14:46:00'::timestamptz
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
SELECT c.id, c.home_store_id, 128, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289622'
FROM c WHERE 128 <> 0
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
    '+12603876530', 'User 6530', NULL, s.id, '22289624',
    36, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-09-20T13:20:00'::timestamptz
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
SELECT c.id, c.home_store_id, 36, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289624'
FROM c WHERE 36 <> 0
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
    '+12604313883', 'Cidney Williams', '16cwilliams@clhscadets.com', s.id, '22289625',
    5, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-12-19T11:12:00'::timestamptz
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
SELECT c.id, c.home_store_id, 5, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289625'
FROM c WHERE 5 <> 0
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
    '+12604416644', 'User 6644', NULL, s.id, '22289626',
    44, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-03-17T15:58:00'::timestamptz
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
SELECT c.id, c.home_store_id, 44, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289626'
FROM c WHERE 44 <> 0
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
    '+12604140121', 'Amerisa Miller', NULL, s.id, '22289627',
    197, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-18T08:21:00'::timestamptz
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
SELECT c.id, c.home_store_id, 197, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289627'
FROM c WHERE 197 <> 0
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
    '+12604495841', 'User 5841', NULL, s.id, '22289628',
    48, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-04-03T09:23:00'::timestamptz
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
SELECT c.id, c.home_store_id, 48, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289628'
FROM c WHERE 48 <> 0
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
    '+12602341478', 'User 1478', NULL, s.id, '22289630',
    418, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-05-15T06:28:00'::timestamptz
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
SELECT c.id, c.home_store_id, 168, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289630'
FROM c WHERE 168 <> 0
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
    '+12604102438', 'User 2438', NULL, s.id, '22289631',
    161, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-10-20T12:33:00'::timestamptz
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
SELECT c.id, c.home_store_id, 161, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289631'
FROM c WHERE 161 <> 0
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
    '+12609993230', 'User 3230', NULL, s.id, '22289632',
    218, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2024-08-24T08:47:00'::timestamptz
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
SELECT c.id, c.home_store_id, 218, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289632'
FROM c WHERE 218 <> 0
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
    '+12607559281', 'User 9281', NULL, s.id, '22289633',
    81, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-05-16T13:48:00'::timestamptz
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
SELECT c.id, c.home_store_id, 81, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289633'
FROM c WHERE 81 <> 0
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
    '+12602673242', 'User 3242', NULL, s.id, '22289634',
    213, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-08-02T06:06:00'::timestamptz
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
SELECT c.id, c.home_store_id, 213, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289634'
FROM c WHERE 213 <> 0
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
    '+19727307054', 'User 7054', NULL, s.id, '22289637',
    12, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2024-11-22T15:29:00'::timestamptz
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
SELECT c.id, c.home_store_id, 12, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289637'
FROM c WHERE 12 <> 0
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


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12482125315', 'User 5315', NULL, s.id, '22289660',
    133, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-12-10T14:00:00'::timestamptz
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
SELECT c.id, c.home_store_id, 133, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289660'
FROM c WHERE 133 <> 0
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
    '+18609443092', 'User 3092', NULL, s.id, '22289661',
    482, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-08-07T14:14:00'::timestamptz
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
SELECT c.id, c.home_store_id, 232, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289661'
FROM c WHERE 232 <> 0
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
    '+12604478249', 'Priscilla', NULL, s.id, '22289662',
    0, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-13T14:38:00'::timestamptz
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289662'
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
    '+12607157405', 'User 7405', NULL, s.id, '22289663',
    22, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-24T06:08:00'::timestamptz
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
SELECT c.id, c.home_store_id, 22, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289663'
FROM c WHERE 22 <> 0
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
    '+12607056006', 'User 6006', NULL, s.id, '22289664',
    0, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-13T13:56:00'::timestamptz
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289664'
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
    '+12607398960', 'User 8960', NULL, s.id, '22289665',
    308, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-02-14T08:07:00'::timestamptz
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
SELECT c.id, c.home_store_id, 58, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289665'
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
    '+12604524462', 'User 4462', NULL, s.id, '22289666',
    120, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-08-24T10:08:00'::timestamptz
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
SELECT c.id, c.home_store_id, 120, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289666'
FROM c WHERE 120 <> 0
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
    '+12603871285', 'User 1285', NULL, s.id, '22289667',
    0, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-13T10:35:00'::timestamptz
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289667'
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
    '+19375973408', 'User 3408', NULL, s.id, '22289668',
    30, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-04-14T09:55:00'::timestamptz
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
SELECT c.id, c.home_store_id, 30, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289668'
FROM c WHERE 30 <> 0
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
    '+12602551761', 'User 1761', NULL, s.id, '22289669',
    651, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-27T11:14:00'::timestamptz
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
SELECT c.id, c.home_store_id, 151, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289669'
FROM c WHERE 151 <> 0
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
    '+12603480234', 'Victoria', NULL, s.id, '22289670',
    350, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-07-18T12:48:00'::timestamptz
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
SELECT c.id, c.home_store_id, 100, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289670'
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
    '+12607402158', 'User 2158', NULL, s.id, '22289671',
    21, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-10T08:03:00'::timestamptz
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
SELECT c.id, c.home_store_id, 21, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289671'
FROM c WHERE 21 <> 0
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
    '+12604490967', 'User 0967', NULL, s.id, '22289672',
    68, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-11T08:44:00'::timestamptz
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
SELECT c.id, c.home_store_id, 68, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289672'
FROM c WHERE 68 <> 0
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
    '+12602579843', 'User 9843', NULL, s.id, '22289673',
    13, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-09T13:20:00'::timestamptz
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
SELECT c.id, c.home_store_id, 13, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289673'
FROM c WHERE 13 <> 0
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
    '+12603852539', 'Mechel Minton', NULL, s.id, '22289674',
    247, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-05T13:27:00'::timestamptz
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
SELECT c.id, c.home_store_id, 247, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289674'
FROM c WHERE 247 <> 0
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
    '+12602061334', 'User 1334', 'shaikirasimon12@gmail.com', s.id, '22289675',
    648, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-06T06:09:00'::timestamptz
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
SELECT c.id, c.home_store_id, 148, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289675'
FROM c WHERE 148 <> 0
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
    '+12605793643', 'User 3643', NULL, s.id, '22289676',
    99, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-03-20T15:35:00'::timestamptz
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
SELECT c.id, c.home_store_id, 99, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289676'
FROM c WHERE 99 <> 0
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
    '+14849085676', 'User 5676', NULL, s.id, '22289677',
    51, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-09T12:26:00'::timestamptz
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
SELECT c.id, c.home_store_id, 51, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289677'
FROM c WHERE 51 <> 0
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
    '+15137802216', 'User 2216', NULL, s.id, '22289678',
    191, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-01-03T06:28:00'::timestamptz
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
SELECT c.id, c.home_store_id, 191, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289678'
FROM c WHERE 191 <> 0
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
    '+12604182376', 'User 2376', NULL, s.id, '22289679',
    125, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-12-23T13:03:00'::timestamptz
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
SELECT c.id, c.home_store_id, 125, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289679'
FROM c WHERE 125 <> 0
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


WITH s AS (SELECT id FROM stores WHERE name = 'Hollywood Beauty'),
c AS (
  INSERT INTO customers (
    phone, name, email, home_store_id, legacy_tapmango_id,
    lifetime_points_at_migration, source,
    sms_subscribed, sms_opt_out_at, email_subscribed, email_opt_out_at,
    registered_at, last_seen_at
  )
  SELECT
    '+12608884198', 'User 4198', NULL, s.id, '22289701',
    7, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-07T10:09:00'::timestamptz
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
SELECT c.id, c.home_store_id, 7, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289701'
FROM c WHERE 7 <> 0
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
    '+12602063724', 'Sheneeka', NULL, s.id, '22289702',
    328, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2022-05-02T08:28:00'::timestamptz
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
SELECT c.id, c.home_store_id, 133, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289702'
FROM c WHERE 133 <> 0
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
    '+12602093699', 'User 3699', NULL, s.id, '22289703',
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289703'
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
    '+12609993418', 'User 3418', NULL, s.id, '22289704',
    41, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-06-12T10:50:00'::timestamptz
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
SELECT c.id, c.home_store_id, 41, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289704'
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
    '+12605806700', 'User 6700', NULL, s.id, '22289705',
    557, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-03-20T15:57:00'::timestamptz
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
SELECT c.id, c.home_store_id, 102, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289705'
FROM c WHERE 102 <> 0
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
    '+16039308816', 'User 8816', NULL, s.id, '22289706',
    108, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-09-05T11:39:00'::timestamptz
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
SELECT c.id, c.home_store_id, 108, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289706'
FROM c WHERE 108 <> 0
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
    '+12604871019', 'Yolanda', NULL, s.id, '22289707',
    57, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-06-10T13:26:00'::timestamptz
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
SELECT c.id, c.home_store_id, 57, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289707'
FROM c WHERE 57 <> 0
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
    '+12602063699', 'Kelli', NULL, s.id, '22289708',
    98, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-01-16T15:06:00'::timestamptz
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
SELECT c.id, c.home_store_id, 98, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289708'
FROM c WHERE 98 <> 0
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
    '+12603760067', 'User 0067', NULL, s.id, '22289709',
    311, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-03-25T09:14:00'::timestamptz
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
SELECT c.id, c.home_store_id, 61, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289709'
FROM c WHERE 61 <> 0
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
    '+12606339541', 'User 9541', NULL, s.id, '22289710',
    10, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-05-26T14:11:00'::timestamptz
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
SELECT c.id, c.home_store_id, 10, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289710'
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
    '+12602064017', 'User 4017', NULL, s.id, '22289712',
    42, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-05T08:45:00'::timestamptz
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
SELECT c.id, c.home_store_id, 42, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289712'
FROM c WHERE 42 <> 0
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
    '+15743006399', 'User 6399', NULL, s.id, '22289713',
    79, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-12-06T13:16:00'::timestamptz
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
SELECT c.id, c.home_store_id, 79, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289713'
FROM c WHERE 79 <> 0
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
    '+12602346003', 'User 6003', NULL, s.id, '22289714',
    1836, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-07-11T15:05:00'::timestamptz
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
SELECT c.id, c.home_store_id, 67, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289714'
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
    '+12607399228', 'User 9228', NULL, s.id, '22289715',
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289715'
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
    '+12604471731', 'User 1731', NULL, s.id, '22289716',
    0, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2021-06-26T10:25:00'::timestamptz
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
SELECT c.id, c.home_store_id, 0, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289716'
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
    '+12603858517', 'User 8517', NULL, s.id, '22289717',
    9, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2020-11-04T14:47:00'::timestamptz
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
SELECT c.id, c.home_store_id, 9, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289717'
FROM c WHERE 9 <> 0
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
    '+13172008454', 'User 8454', NULL, s.id, '22289718',
    1647, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-05-24T08:51:00'::timestamptz
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
SELECT c.id, c.home_store_id, 222, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289718'
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
    '+12607559371', 'Preonda', NULL, s.id, '22289720',
    79, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2025-08-08T13:38:00'::timestamptz
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
SELECT c.id, c.home_store_id, 79, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289720'
FROM c WHERE 79 <> 0
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
    '+15748474711', 'User 4711', NULL, s.id, '22289721',
    156, 'migration'::customer_source_enum,
    false, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2023-03-10T10:20:00'::timestamptz
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
SELECT c.id, c.home_store_id, 156, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289721'
FROM c WHERE 156 <> 0
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
    '+12404861198', 'User 1198', NULL, s.id, '22289722',
    1121, 'migration'::customer_source_enum,
    true, NULL,
    false, NULL,
    '2021-09-10T15:13:00'::timestamptz,
    '2026-07-02T15:43:00'::timestamptz
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
SELECT c.id, c.home_store_id, 164, 'migration_opening'::ledger_reason_enum, 'import'::ledger_ref_type_enum, 'import:' || '22289722'
FROM c WHERE 164 <> 0
ON CONFLICT (idempotency_key) DO NOTHING;
