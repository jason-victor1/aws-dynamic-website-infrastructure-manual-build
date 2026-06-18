#!/usr/bin/env bash
set -euo pipefail

# Sanitized database migration template.
# Replace placeholders before use.
# Do not commit real secrets, endpoints, or account-specific values.

AWS_REGION="<region>"
S3_SQL_URI="s3://<bucket-name>/<migration-file>.sql"
DB_HOST="<rds-endpoint>"
DB_NAME="<database-name>"
SECRET_ID="<secrets-manager-secret-id>"

echo "[INFO] Downloading SQL migration file from S3..."
aws s3 cp "$S3_SQL_URI" ./migration.sql --region "$AWS_REGION"

echo "[INFO] Retrieving database secret metadata..."
SECRET_JSON="$(aws secretsmanager get-secret-value   --secret-id "$SECRET_ID"   --region "$AWS_REGION"   --query SecretString   --output text)"

# Requires jq.
DB_USERNAME="$(echo "$SECRET_JSON" | jq -r '.username')"
DB_PASSWORD="$(echo "$SECRET_JSON" | jq -r '.password')"

echo "[INFO] Running migration..."
MYSQL_PWD="$DB_PASSWORD" mysql   --host="$DB_HOST"   --user="$DB_USERNAME"   "$DB_NAME" < migration.sql

echo "[INFO] Migration complete."
