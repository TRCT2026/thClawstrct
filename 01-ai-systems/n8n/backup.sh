#!/bin/bash
# ============================================
# n8n Backup Script
# วิธีใช้: bash backup.sh
# Cron daily:  0 3 * * * /opt/n8n-stack/backup.sh >> /var/log/n8n-backup.log 2>&1
# ============================================

set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/opt/backups/n8n}"
STACK_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=14

mkdir -p "$BACKUP_DIR"

cd "$STACK_DIR"

# 1) Dump PostgreSQL
echo "[$(date)] Dumping PostgreSQL..."
docker compose exec -T postgres pg_dump -U "${POSTGRES_USER:-n8n}" "${POSTGRES_DB:-n8n}" \
	| gzip > "$BACKUP_DIR/db_${TIMESTAMP}.sql.gz"

# 2) Backup n8n volume (workflows, credentials encrypted)
echo "[$(date)] Backing up n8n data volume..."
docker run --rm \
	-v n8n-stack_n8n_data:/data:ro \
	-v "$BACKUP_DIR":/backup \
	alpine tar czf "/backup/n8n_data_${TIMESTAMP}.tar.gz" -C /data .

# 3) Backup .env (encryption keys!)
cp .env "$BACKUP_DIR/env_${TIMESTAMP}.bak"
chmod 600 "$BACKUP_DIR/env_${TIMESTAMP}.bak"

# 4) Prune old backups
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete

echo "[$(date)] Backup completed → $BACKUP_DIR"
ls -lh "$BACKUP_DIR" | tail -10
