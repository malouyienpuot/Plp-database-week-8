# Capstone Walkthrough — Student Learning Centre Management System

**Presenter:** Malou Yien  
**Project:** PLP Database Week 8 Capstone

## Slide 1 — Problem and goal
Learning centres need a reliable way to manage courses, enrolments, and attendance while keeping each centre's data private.

## Slide 2 — Requirements
- Manage centres, accounts, courses, enrolments, and attendance.
- Enforce data integrity and tenant isolation.
- Keep an audit trail for critical changes.
- Support reporting, backups, and repeatable database setup.

## Slide 3 — ER design
Show `docs/er-diagram.dbml` rendered in dbdiagram.io. Explain the many-to-many relationship between students and courses through enrolments, and the one-to-many relationship from enrolments to attendance records.

## Slide 4 — PostgreSQL schema and migrations
Explain V1 core tables, V2 indexes, V3 audit triggers, V4 RLS and roles, and V5 synthetic demo data. Demonstrate migration from an empty development database.

## Slide 5 — NoSQL/cache choice
Redis is optional and used only for short-lived course summary caching. PostgreSQL remains authoritative for records, constraints, and transactions. A cache miss or Redis outage falls back to PostgreSQL.

## Slide 6 — Query optimization
Show actual before/after `EXPLAIN (ANALYZE, BUFFERS)` plans from `docs/query-optimization.md`. Explain index choice and measured results; do not claim gains without evidence.

## Slide 7 — Security and recovery
Demonstrate least-privilege roles, tenant-scoped RLS, parameterized queries, a custom-format backup, and a successful restore test in a disposable database.

## Slide 8 — Lessons and next steps
Run a peer review of the ER diagram, load representative data, capture benchmark evidence, automate backup verification, and add integration tests for tenant isolation.

---
**Reserved by Malou Yien**
