#!/bin/sh
CUR_DIR=$(cd "$(dirname $0)"; pwd)

mkdir -p /var/log

if [ "$DISABLE_TM" = "true" -o "$DISABLE_TM" = "1" ]; then
	mv /etc/supervisor/conf.d/cli.conf /etc/supervisor/conf.d/cli.conf.bak
else
	[ -f "/etc/supervisor/conf.d/cli.conf" ] && {
		[ -z "$DEVICE_NAME" ] && DEVICE_NAME="$(hostname)"
		[ -z "$DEVICE_NAME" ] && DEVICE_NAME=$(date +%Y%m%d-%H%M) || DEVICE_NAME="$DEVICE_NAME-$(date +%Y%m%d-%H%M)"
		sed -Ei "s/%DEVICE_NAME%/$DEVICE_NAME/g" /etc/supervisor/conf.d/cli.conf
	}
fi

if [ "$DISABLE_HG" = "true" -o "$DISABLE_HG" = "1" ]; then
	mv /etc/supervisor/conf.d/hg.conf /etc/supervisor/conf.d/hg.conf.bak
else
	[ -f "/etc/supervisor/conf.d/hg.conf" ] && {
		[ -z "$DEVICE_NAME" ] && DEVICE_NAME="$(hostname)"
		[ -z "$DEVICE_NAME" ] && DEVICE_NAME=$(date +%Y%m%d-%H%M) || DEVICE_NAME="$DEVICE_NAME-$(date +%Y%m%d-%H%M)"
		sed -Ei "s/%DEVICE_NAME%/$DEVICE_NAME/g" /etc/supervisor/conf.d/hg.conf
	}
fi

if [ "$DISABLE_PC" = "true" -o "$DISABLE_PC" = "1" ]; then
	mv /etc/supervisor/conf.d/pc.conf /etc/supervisor/conf.d/pc.conf.bak
else
	[ -f "/etc/supervisor/conf.d/pc.conf" ] && {
		[ -z "$DEVICE_NAME" ] && DEVICE_NAME="$(hostname)"
		[ -z "$DEVICE_NAME" ] && DEVICE_NAME=$(date +%Y%m%d-%H%M) || DEVICE_NAME="$DEVICE_NAME-$(date +%Y%m%d-%H%M)"
		sed -Ei "s/%DEVICE_NAME%/$DEVICE_NAME/g" /etc/supervisor/conf.d/pc.conf
	}
fi

if [ -x /usr/bin/nezha-agent ] && [ -f /etc/nezha-agent/config.yml ] && [ -n "$NZ_SERVER" ] && [ -n "$NZ_CLIENT_SECRET" ]; then
	[ -z "$NZ_UUID" ] && NZ_UUID=$(uuidgen)
	# /usr/bin/nezha-agent -c /etc/nezha-agent/config.yml
	cat <<-EOF >/etc/nezha-agent/config.yml
	client_secret: ${NZ_CLIENT_SECRET}
	debug: ${NZ_DEBUG:-true}
	disable_auto_update: true
	disable_command_execute: false
	disable_force_update: true
	disable_nat: false
	disable_send_query: false
	gpu: false
	insecure_tls: true
	ip_report_period: 1800
	report_delay: 4
	server: ${NZ_SERVER}
	skip_connection_count: true
	skip_procs_count: true
	temperature: false
	tls: ${NZ_TLS:-true}
	use_gitee_to_upgrade: false
	use_ipv6_country_code: false
	uuid: ${NZ_UUID}
	EOF
else
	mv /etc/supervisor/conf.d/nezha.conf /etc/supervisor/conf.d/nezha.conf.bak
fi

if [ -z "$PORT_WS" ]; then
	mv /etc/supervisor/conf.d/node_ws.conf /etc/supervisor/conf.d/node_ws.conf.bak
else
	sed -Ei "s/%PORT_WS%/$PORT_WS/g" /etc/supervisor/conf.d/node_ws.conf
fi

if [ -z "$PORT_XHTTP" ]; then
	mv /etc/supervisor/conf.d/node_xhttp.conf /etc/supervisor/conf.d/node_xhttp.conf.bak
else
	sed -Ei "s/%PORT_XHTTP%/$PORT_XHTTP/g" /etc/supervisor/conf.d/node_xhttp.conf
fi

[ -z "$PORT_ARGO" ] && PORT_ARGO=$SERVER_PORT
[ -z "$PORT_ARGO" ] && PORT_ARGO=$PORT
if [ -z "$ARGO_AUTH" -o -z "$ARGO_DOMAIN" -o -z "$PORT_ARGO" -o "$PORT_ARGO" = "$PORT_WS" -o "$PORT_ARGO" = "$PORT_XHTTP" ]; then
	mv /etc/supervisor/conf.d/node.conf /etc/supervisor/conf.d/node.conf.bak
else
	sed -Ei "s/%SERVER_PORT%/$PORT_ARGO/g" /etc/supervisor/conf.d/node.conf
fi

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n
