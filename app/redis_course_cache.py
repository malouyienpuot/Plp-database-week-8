"""Optional tenant-scoped Redis cache for course summaries.

PostgreSQL remains the source of truth. Cache only non-sensitive summaries.
Install with: pip install redis psycopg[binary]
Set REDIS_URL and DATABASE_URL in the environment.
Reserved by Malou Yien.
"""
import json
import os
from typing import Any

import redis
import psycopg
from psycopg.rows import dict_row

REDIS_URL = os.environ.get("REDIS_URL", "redis://localhost:6379/0")
DATABASE_URL = os.environ["DATABASE_URL"]
CACHE_TTL_SECONDS = 300

cache = redis.Redis.from_url(REDIS_URL, decode_responses=True)


def get_course_summary(tenant_id: int) -> list[dict[str, Any]]:
    # Tenant is part of the key to avoid cross-tenant cache collisions.
    key = f"tenant:{tenant_id}:course-summary:v1"
    try:
        cached = cache.get(key)
        if cached:
            return json.loads(cached)
    except redis.RedisError:
        # Redis is optional: continue to PostgreSQL when the cache is down.
        pass

    with psycopg.connect(DATABASE_URL, row_factory=dict_row) as conn:
        with conn.cursor() as cur:
            # Set tenant context inside this transaction; RLS uses this setting.
            cur.execute("SELECT set_config('app.tenant_id', %s, true)", (str(tenant_id),))
            cur.execute(
                """
                SELECT c.id, c.title, COUNT(e.id)::int AS enrolled_students
                FROM courses AS c
                LEFT JOIN enrollments AS e
                  ON e.tenant_id = c.tenant_id
                 AND e.course_id = c.id
                 AND e.status = %s
                WHERE c.tenant_id = %s AND c.is_active = TRUE
                GROUP BY c.id, c.title
                ORDER BY c.title
                """,
                ("enrolled", tenant_id),
            )
            rows = [dict(row) for row in cur.fetchall()]

    try:
        cache.setex(key, CACHE_TTL_SECONDS, json.dumps(rows))
    except redis.RedisError:
        pass
    return rows


def invalidate_course_summary(tenant_id: int) -> None:
    """Call after a successful course/enrolment change for this tenant."""
    try:
        cache.delete(f"tenant:{tenant_id}:course-summary:v1")
    except redis.RedisError:
        pass
