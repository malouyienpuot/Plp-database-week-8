#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?Set DATABASE_URL to a PostgreSQL connection string}"
: "${BACKUP_FILE:?Set BACKUP_FILE to an existing custom-format dump}"
: "${RESTORE_TEST_DB:?Set RESTORE_TEST_DB to a disposable database name}"

if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "Backup file not found: $BACKUP_FILE" >&2
  exit 1
fi

echo "This will drop and recreate the disposable database: $RESTORE_TEST_DB"
echo "Do not use a production database name."
read -r -p "Type RESTORE to continue: " confirmation
[[ "$confirmation" == "RESTORE" ]] || { echo "Cancelled."; exit 1; }

admin_url="${DATABASE_URL%/*}/postgres"
psql "$admin_url" -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS \"$RESTORE_TEST_DB\";"
psql "$admin_url" -v ON_ERROR_STOP=1 -c "CREATE DATABASE \"$RESTORE_TEST_DB\";"
restore_url="${DATABASE_URL%/*}/$RESTORE_TEST_DB"
pg_restore --no-owner --dbname="$restore_url" "$BACKUP_FILE"

psql "$restore_url" -v ON_ERROR_STOP=1 -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;"
echo "Restore command completed. Check row counts and RLS behavior before marking the test successful."
