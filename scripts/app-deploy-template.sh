#!/usr/bin/env bash
set -euo pipefail

# Sanitized application deployment template.
# Replace placeholders before use.
# Do not commit real secrets, endpoints, or account-specific values.

AWS_REGION="<region>"
S3_APP_URI="s3://<bucket-name>/<application-package>.zip"
APP_DIR="/var/www/html"
SECRET_ID="<secrets-manager-secret-id>"
DB_HOST="<rds-endpoint>"
DB_NAME="<database-name>"

echo "[INFO] Installing packages..."
sudo dnf update -y
sudo dnf install -y httpd php php-mysqlnd unzip jq

echo "[INFO] Downloading application package..."
aws s3 cp "$S3_APP_URI" /tmp/app.zip --region "$AWS_REGION"

echo "[INFO] Deploying application..."
sudo rm -rf "$APP_DIR"/*
sudo unzip -o /tmp/app.zip -d "$APP_DIR"
sudo chown -R apache:apache "$APP_DIR"

echo "[INFO] Retrieving database secret..."
SECRET_JSON="$(aws secretsmanager get-secret-value   --secret-id "$SECRET_ID"   --region "$AWS_REGION"   --query SecretString   --output text)"

DB_USERNAME="$(echo "$SECRET_JSON" | jq -r '.username')"
DB_PASSWORD="$(echo "$SECRET_JSON" | jq -r '.password')"

echo "[INFO] Creating sanitized .env file..."
sudo tee "$APP_DIR/.env" > /dev/null <<EOF
APP_ENV=lab
APP_URL=https://<example-domain>

DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=3306
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
EOF

echo "[INFO] Starting Apache..."
sudo systemctl enable httpd
sudo systemctl restart httpd

echo "[INFO] Deployment complete."
