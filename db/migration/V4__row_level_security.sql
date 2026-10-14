-- V4: Least-privilege roles and tenant isolation.
-- Role creation is guarded so the migration is safe in environments where roles exist.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'capstone_app') THEN
        CREATE ROLE capstone_app LOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'capstone_readonly') THEN
        CREATE ROLE capstone_readonly LOGIN;
    END IF;
END $$;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO capstone_app, capstone_readonly;

GRANT SELECT, INSERT, UPDATE, DELETE ON tenants, app_users, courses, enrollments, attendance TO capstone_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO capstone_app;
GRANT SELECT ON tenants, app_users, courses, enrollments, attendance TO capstone_readonly;

ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_users FORCE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses FORCE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments FORCE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance FORCE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs FORCE ROW LEVEL SECURITY;

CREATE POLICY app_users_tenant_policy ON app_users
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::BIGINT)
    WITH CHECK (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::BIGINT);
CREATE POLICY courses_tenant_policy ON courses
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::BIGINT)
    WITH CHECK (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::BIGINT);
CREATE POLICY enrollments_tenant_policy ON enrollments
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::BIGINT)
    WITH CHECK (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::BIGINT);
CREATE POLICY attendance_tenant_policy ON attendance
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::BIGINT)
    WITH CHECK (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::BIGINT);
CREATE POLICY audit_logs_tenant_policy ON audit_logs
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::BIGINT);

-- Tenant table is visible to authenticated app roles; add stricter tenant lookup
-- policies here if the production identity model requires them.
GRANT SELECT ON audit_logs TO capstone_readonly;
-- The app role is deliberately not granted direct write access to audit_logs.
