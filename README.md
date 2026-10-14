# PLP Database Week 8 — Capstone Build Sprint

**Project:** Student Learning Centre Management System  
**Author / Reserved by:** Malou Yien  
**Repository:** https://github.com/malouyienpuot/Plp-database-week-8

## 1. Project overview
This capstone models a learning centre that manages tenants/centres, staff and student accounts, courses, enrolments, and attendance. PostgreSQL is the source of truth. Redis is an optional cache for frequently read course summaries; it is not used for permanent records.

## 2. Requirements summary
- Isolate data between learning centres (tenants).
- Store course information and student enrolments.
- Record attendance by enrolment and class date.
- Keep a tamper-evident-style application audit trail for critical table changes (the audit log itself still requires database permissions and backup protection).
- Apply least privilege and PostgreSQL row-level security (RLS) to tenant-owned data.
- Support reports for enrolment counts and attendance rates.
- Provide ordered Flyway migrations, demo data, backup/restore instructions, and a repeatable query-plan measurement process.

### Scope and assumptions
- Each account belongs to one centre and has a role such as admin, trainer, or student.
- A student can enrol in multiple courses; a course can have multiple students.
- Attendance is recorded once per enrolment per class date.
- Demo credentials and real student personal data are intentionally excluded.
- The application must set `app.tenant_id` for each database session/transaction before querying tenant-protected tables.

## 3. Repository layout
- `db/migration/V1__core_tables.sql` — core entities and constraints
- `db/migration/V2__indexes.sql` — reporting and lookup indexes
- `db/migration/V3__audit_and_triggers.sql` — audit log and audit triggers
- `db/migration/V4__row_level_security.sql` — least-privilege roles and RLS policies
- `db/migration/V5__seed_demo_data.sql` — safe synthetic data
- `docs/requirements.md` — requirements and design notes
- `docs/er-diagram.dbml` — ER diagram source for dbdiagram.io
- `docs/query-optimization.md` — explain/analyze evidence template
- `docs/security-and-backup.md` — security checklist and restore drill
- `docs/walkthrough-presentation.md` — short presentation outline
- `scripts/backup.sh` and `scripts/restore-test.sh` — backup and restore test examples
- `app/redis_course_cache.py` — optional Redis cache example
- `flyway.conf.example` — Flyway configuration template

## 4. Prerequisites
PostgreSQL 15+, Flyway, and (optionally) Redis 7+ and Python 3.10+. Set credentials through environment variables or a local untracked configuration file; never commit passwords.

## 5. Configure and migrate
Create an empty database named `capstone`, then configure Flyway using `flyway.conf.example` as a guide. Ensure Flyway's database user can create the schema objects and policies. In a local development database only, run:

```bash
flyway -configFiles=flyway.conf migrate
```

For a disposable development database, `flyway clean migrate` can rebuild everything, but **clean permanently drops database objects**. Do not enable `clean` in production. Configure `flyway.cleanDisabled=false` only for a disposable local database.

Set tenant context in a session before querying protected tables:
```sql
SET app.tenant_id = '1';
SELECT id, title FROM courses;
```
For application code, prefer transaction-scoped `set_config('app.tenant_id', $1, true)` so context does not leak across pooled connections.

## 6. Important implementation notes
- The RLS policy uses `current_setting('app.tenant_id', true)`; if the setting is missing, access is denied.
- The SQL creates application roles only when absent. Review role ownership and grants for your deployment environment.
- The seed migration sets tenant context and inserts fictional demo records.
- Query timings must be measured on your own machine with representative data. No performance numbers are claimed in this repository until actual `EXPLAIN (ANALYZE, BUFFERS)` output is recorded.
- Redis is only a cache. If it is unavailable, the application should query PostgreSQL; cache entries should have a TTL and tenant-scoped keys.

## 7. Backup
```bash
chmod +x scripts/*.sh
DATABASE_URL='postgresql://backup_user:YOUR_PASSWORD@localhost:5432/capstone' ./scripts/backup.sh
```
Test restores using a disposable database, not over a live database.

## 8. Ownership
**Reserved by Malou Yien.**  
This project was prepared for the PLP Database Week 8 Capstone Build Sprint.
