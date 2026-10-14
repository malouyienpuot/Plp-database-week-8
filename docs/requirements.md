# Requirements Summary — Student Learning Centre Management System

**Owner:** Malou Yien

## Purpose
Provide a secure relational database for learning centres to manage courses, student accounts, enrolments, and attendance while keeping each centre's records isolated.

## Functional requirements
1. A centre (tenant) can maintain its own staff/student accounts and courses.
2. Every account has a unique email within its centre and a role.
3. Students can enrol in courses; duplicate enrolment in the same course is prohibited.
4. Attendance is linked to an enrolment and a class date; a duplicate attendance entry for the same enrolment/date is prohibited.
5. Reports can list course enrolment totals and calculate attendance percentages.
6. Critical changes to courses, enrolments, and attendance are written to an audit table.
7. Optional Redis caching accelerates frequently requested course summaries without becoming the system of record.

## Non-functional requirements
- Tenant isolation through PostgreSQL row-level security.
- Least-privilege database roles; no application superuser.
- Referential integrity, not-null constraints, and uniqueness constraints.
- Ordered Flyway migrations for repeatable setup.
- Backups in custom PostgreSQL format and a documented restore test.
- Parameterized SQL in application code.
- Performance claims supported by measured `EXPLAIN (ANALYZE, BUFFERS)` plans.

## Main entities and relationships
- `tenants` 1-to-many `app_users`
- `tenants` 1-to-many `courses`
- `app_users` (students) many-to-many `courses` through `enrollments`
- `enrollments` 1-to-many `attendance`
- `audit_logs` records changes to selected tables and references the tenant when known

## Data handling
The sample schema stores email addresses but no passwords, medical records, or other sensitive real-world data. In a production system, passwords must be stored only as salted password hashes using a suitable password-hashing library (such as Argon2id), not reversible encryption or plain text. Secrets must be supplied through a secret manager/environment and excluded from Git.

## Design feedback checkpoint
Before implementing SQL in a real team, ask a reviewer to confirm: tenant boundaries, role permissions, whether students can see other students, attendance correction workflow, audit retention, deletion policy, and local legal/privacy requirements. This repository includes a proposed design; it does not claim an external reviewer has approved it.
