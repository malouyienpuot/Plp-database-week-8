# Query Optimization Evidence

**Reserved by Malou Yien**

## Query A — Active courses and enrolment totals
Question: Which active courses belong to the current tenant, and how many active enrolments does each have?

Run this with demo tenant context:
```sql
SET app.tenant_id = '1';

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT c.id, c.title, COUNT(e.id) AS enrolled_students
FROM courses AS c
LEFT JOIN enrollments AS e
  ON e.tenant_id = c.tenant_id
 AND e.course_id = c.id
 AND e.status = 'enrolled'
WHERE c.tenant_id = 1
  AND c.is_active = TRUE
GROUP BY c.id, c.title
ORDER BY c.title;
```

### Evidence log
1. **QUERY:** Active course list and enrolled student counts.
2. **BEFORE PLAN:** Run the query before adding the relevant index in a disposable database and paste the real output here.
3. **CHANGE:** Migration V2 adds `courses_tenant_active_title_idx` and `enrollments_tenant_course_status_idx` to support tenant filtering and course/status joins.
4. **AFTER PLAN:** Run the same `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)` after the index exists; paste the real output here.
5. **RESULT:** Record actual execution time, buffers, and scan types from your environment. Do not copy example timings or claim an improvement without measurements.

## Query B — Attendance summary
```sql
SET app.tenant_id = '1';

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT a.class_date,
       COUNT(*) FILTER (WHERE a.status = 'present') AS present_count,
       COUNT(*) FILTER (WHERE a.status = 'absent') AS absent_count,
       COUNT(*) AS recorded_count
FROM attendance AS a
WHERE a.tenant_id = 1
  AND a.class_date >= CURRENT_DATE - 30
GROUP BY a.class_date
ORDER BY a.class_date;
```

### Evidence log
- **BEFORE PLAN:** Paste actual output from a baseline before the index is added.
- **CHANGE:** `attendance_tenant_date_status_idx` supports tenant/date filtering and status-based reporting.
- **AFTER PLAN:** Paste the actual plan after migration V2.
- **RESULT:** Compare execution time and shared buffer reads; note that small demo tables may correctly use sequential scans because index startup cost is not worthwhile.

## Reproducibility notes
- Record PostgreSQL version, row counts, hardware/environment, and whether the cache was warm.
- Use the same data volume and query parameters for before/after.
- Do not use `EXPLAIN ANALYZE` on mutating statements unless wrapped safely in a transaction and rolled back.
- The repository intentionally contains no fabricated benchmark numbers; the learner must capture them from a real database.
