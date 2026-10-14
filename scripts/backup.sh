#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?Set DATABASE_URL to a PostgreSQL connection string}"
BACKUP_DIR="${BACKUP_DIR:-backups}"
mkdir -p "$BACKUP_DIR"

backup_file="$BACKUP_DIR/capstone_$(date +%F_%H%M%S).dump"
pg_dump --format=custom --no-owner --file="$backup_file" "$DATABASE_URL"
pg_restore --list "$backup_file" >/dev/null

echo "Backup created and archive list verified: $backup_file"
echo "Protect this file; move it to encrypted, access-controlled storage."
