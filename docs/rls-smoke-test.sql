-- Run with an authorized test role after migrations.
-- This is a manual smoke test; use a disposable environment.
-- Tenant 1 should see only tenant 1 records.
BEGIN;
SELECT set_config('app.tenant_id', '1', true);
SELECT id, tenant_id, title FROM courses ORDER BY id;
-- Expected: only courses with tenant_id = 1.
ROLLBACK;

-- Tenant 2 should see only tenant 2 records.
BEGIN;
SELECT set_config('app.tenant_id', '2', true);
SELECT id, tenant_id, title FROM courses ORDER BY id;
-- Expected: only courses with tenant_id = 2.
ROLLBACK;

-- Missing context should return no rows from tenant-protected tables.
BEGIN;
RESET app.tenant_id;
SELECT id, tenant_id, title FROM courses ORDER BY id;
-- Expected: no rows.
ROLLBACK;
