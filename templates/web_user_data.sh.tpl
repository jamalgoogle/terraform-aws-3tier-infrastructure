#!/bin/bash
set -euxo pipefail
dnf install -y httpd

# Web tier: serve static pages and proxy /api to the app tier (internal ALB)
cat > /etc/httpd/conf.d/app-proxy.conf <<'CONF'
ProxyPreserveHost On
ProxyPass /api http://${app_endpoint}/
ProxyPassReverse /api http://${app_endpoint}/
CONF

echo "web tier ok" > /var/www/html/index.html
systemctl enable --now httpd
