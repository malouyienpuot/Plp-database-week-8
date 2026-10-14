-- V3: Capture row-level changes for critical tables.
CREATE OR REPLACE FUNCTION write_audit_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    old_row JSONB;
    new_row JSONB;
    row_tenant BIGINT;
    row_key TEXT;
BEGIN
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        old_row := to_jsonb(OLD);
        row_tenant := NULLIF(old_row ->> 'tenant_id', '')::BIGINT;
        row_key := old_row ->> 'id';
    END IF;

    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        new_row := to_jsonb(NEW);
        row_tenant := COALESCE(row_tenant, NULLIF(new_row ->> 'tenant_id', '')::BIGINT);
        row_key := COALESCE(new_row ->> 'id', row_key);
    END IF;

    INSERT INTO public.audit_logs (tenant_id, table_name, operation, row_id, db_user, old_data, new_data)
    VALUES (row_tenant, TG_TABLE_NAME, TG_OP, row_key, session_user, old_row, new_row);

    IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER courses_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON courses
FOR EACH ROW EXECUTE FUNCTION write_audit_log();

CREATE TRIGGER enrollments_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON enrollments
FOR EACH ROW EXECUTE FUNCTION write_audit_log();

CREATE TRIGGER attendance_audit_trg
AFTER INSERT OR UPDATE OR DELETE ON attendance
FOR EACH ROW EXECUTE FUNCTION write_audit_log();

-- Restrict direct execution of the SECURITY DEFINER function.
REVOKE ALL ON FUNCTION write_audit_log() FROM PUBLIC;
