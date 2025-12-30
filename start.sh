#!/bin/sh
CUR_DIR=$(cd "$(dirname $0)"; pwd)

mkdir -p /var/log

[ -z "$DEVICE_NAME" ] && DEVICE_NAME="$(hostname)"
[ -z "$DEVICE_NAME" ] && DEVICE_NAME=$(date +%Y%m%d-%H%M) || DEVICE_NAME="$DEVICE_NAME-$(date +%Y%m%d-%H%M)"
sed -Ei "s/%DEVICE_NAME%/$DEVICE_NAME/g" /etc/supervisor.d/cli.ini

if [ -x /usr/bin/nezha-agent ] && [ -f /etc/nezha-agent/config.yml ] && [ -n "$NZ_SERVER" ] && [ -n "$NZ_CLIENT_SECRET" ]; then
	[ -z "$NZ_UUID" ] && NZ_UUID=$(uuidgen)
	sed -Ei "s/server: .*/server: $NZ_SERVER/g" /etc/nezha-agent/config.yml
	sed -Ei "s/debug: .*/debug: ${NZ_DEBUG:-true}/g" /etc/nezha-agent/config.yml
	sed -Ei "s/client_secret: .*/client_secret: $NZ_CLIENT_SECRET/g" /etc/nezha-agent/config.yml
	sed -Ei "s/tls: .*/tls: ${NZ_TLS:-true}/g" /etc/nezha-agent/config.yml
	sed -Ei "s/uuid: .*/uuid: $NZ_UUID/g" /etc/nezha-agent/config.yml
	# /usr/bin/nezha-agent -c /etc/nezha-agent/config.yml
else
	rm -rf /etc/supervisor.d/nezha.ini
fi

if [ -z "$PORT_WS" ]; then
	rm -rf /etc/supervisor.d/node_ws.ini
else
	sed -Ei "s/%PORT_WS%/$PORT_WS/g" /etc/supervisor.d/node_ws.ini
fi

if [ -z "$PORT_XHTTP" ]; then
	rm -rf /etc/supervisor.d/node_xhttp.ini
else
	sed -Ei "s/%PORT_XHTTP%/$PORT_XHTTP/g" /etc/supervisor.d/node_xhttp.ini
fi

INDEX_PORT=$SERVER_PORT
[ -z "$INDEX_PORT" ] && INDEX_PORT=$PORT
if [ -z "$ARGO_AUTH" -o -z "$ARGO_DOMAIN" -o -z "$INDEX_PORT" -o "$INDEX_PORT" = "$PORT_WS" -o "$INDEX_PORT" = "$PORT_XHTTP" ]; then
	rm -rf /etc/supervisor.d/node.ini
else
	sed -Ei "s/%SERVER_PORT%/$INDEX_PORT/g" /etc/supervisor.d/node.ini
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf -n
