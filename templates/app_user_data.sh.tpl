#!/bin/bash
set -euxo pipefail
dnf install -y python3

# Config for your real application (read it from systemd EnvironmentFile)
cat > /etc/app.env <<'ENVFILE'
APP_PORT=${app_port}
AWS_REGION=${region}
DB_HOST=${db_host}
DB_SECRET_ARN=${db_secret_arn}
CACHE_HOST=${cache_host}
DYNAMODB_TABLE=${dynamodb_table}
MEDIA_BUCKET=${media_bucket}
ENVFILE

# Placeholder service so health checks pass. Replace with your app.
mkdir -p /opt/app
echo "app tier ok" > /opt/app/index.html

cat > /etc/systemd/system/app.service <<'UNIT'
[Unit]
Description=App tier placeholder
After=network.target

[Service]
EnvironmentFile=/etc/app.env
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 -m http.server ${app_port}
Restart=always

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now app
