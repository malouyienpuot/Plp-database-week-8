# Security, Backup, and Restore Runbook

**Reserved by Malou Yien**

## Security checklist
- [ ] Application connects as `capstone_app`, never as a superuser or database owner.
- [ ] Read-only reporting uses `capstone_readonly`.
- [ ] Set tenant context transaction-locally for every request: `SELECT set_config('app.tenant_id', $1, true)`.
- [ ] Verify RLS is enabled and forced on all tenant-owned/sensitive tables.
- [ ] Use parameterized queries; never concatenate untrusted input into SQL.
- [ ] Keep credentials in a secret manager or environment variables; never commit them.
- [ ] Store passwords only as salted, slow password hashes (Argon2id/bcrypt via a vetted library) if authentication is added.
- [ ] Use TLS in transit and restrict network access to PostgreSQL/Redis.
- [ ] Audit logs are access-restricted and included in backup/retention policy.
- [ ] Backups are encrypted at rest, access-controlled, and periodically restored in a separate environment.
- [ ] Review audit payloads before production; exclude secrets and unnecessary personal data.
- [ ] Add a tenant policy to `tenants` itself if the application needs tenant-specific lookup restrictions.

## Backup
`scripts/backup.sh` creates a custom-format dump. Set `DATABASE_URL` to a backup-capable connection string before running.

## Restore test
1. Create a disposable empty database, for example `capstone_restore_test`.
2. Restore the dump into that database using `pg_restore --no-owner --dbname=...`.
3. Verify expected tables and counts.
4. Run a tenant isolation check with the app role and confirm rows from another tenant are not visible.
5. Delete the disposable database when verification is complete.

## Limitations to address before production
- Database roles may require deployment-specific passwords, grants, and ownership adjustments.
- A custom PostgreSQL setting such as `app.tenant_id` is context, not a complete authentication mechanism by itself. Only trusted application code should set it; use separate verified authorization logic.
- Audit triggers capture row snapshots and may increase storage usage. Define retention and redact fields if the schema later adds personal data.
- The provided schema is a learning capstone baseline and should receive peer/security review before production use.
