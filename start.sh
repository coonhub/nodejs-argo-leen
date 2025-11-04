#!/bin/sh

# 確保 log 目錄存在
mkdir -p /var/log

sed -Ei "s/DEVICE_NAME/railway-$(date +%Y%m%d)/g" /etc/supervisor.d/cli.ini

# 啟動 supervisord
exec /usr/bin/supervisord -c /etc/supervisord.conf -n
