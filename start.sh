#!/bin/sh
CUR_DIR=$(cd "$(dirname $0)"; pwd)

mkdir -p /var/log

if [ "$DISABLE_TM" = "true" -o "$DISABLE_TM" = "1" ]; then
	rm -rf /etc/supervisor.d/cli.ini
else
	[ -f "/etc/supervisor.d/cli.ini" ] && {
		[ -z "$DEVICE_NAME" ] && DEVICE_NAME="$(hostname)"
		[ -z "$DEVICE_NAME" ] && DEVICE_NAME=$(date +%Y%m%d-%H%M) || DEVICE_NAME="$DEVICE_NAME-$(date +%Y%m%d-%H%M)"
		sed -Ei "s/%DEVICE_NAME%/$DEVICE_NAME/g" /etc/supervisor.d/cli.ini
	}
fi

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

[ -z "$PORT_ARGO" ] && PORT_ARGO=$SERVER_PORT
[ -z "$PORT_ARGO" ] && PORT_ARGO=$PORT
if [ -z "$ARGO_AUTH" -o -z "$ARGO_DOMAIN" -o -z "$PORT_ARGO" -o "$PORT_ARGO" = "$PORT_WS" -o "$PORT_ARGO" = "$PORT_XHTTP" ]; then
	rm -rf /etc/supervisor.d/node.ini
else
	sed -Ei "s/%SERVER_PORT%/$PORT_ARGO/g" /etc/supervisor.d/node.ini
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf -n
