#!/bin/sh

mach=$(uname -m)
case "$mach" in
amd64|x86_64)
	os_arch="amd64"
	;;
i386|i686)
	os_arch="386"
	;;
aarch64|arm64)
	os_arch="arm64"
	;;
*arm*)
	os_arch="arm"
	;;
s390x)
	os_arch="s390x"
	;;
riscv64)
	os_arch="riscv64"
	;;
mips)
	os_arch="mips"
	;;
mipsel|mipsle)
	os_arch="mipsle"
	;;
*)
	err "Unknown architecture: $mach"
	exit 1
	;;
esac

system=$(uname)
case "$system" in
	*Linux*)
	os="linux"
	;;
*Darwin*)
	os="darwin"
	;;
*FreeBSD*)
	os="freebsd"
	;;
*)
	echo "Unknown architecture: $system"
	exit 1
	;;
esac
_version=$(curl -m 10 -sL "https://gitee.com/api/v5/repos/naibahq/agent/releases/latest" | awk -F '"' '{for(i=1;i<=NF;i++){if($i=="tag_name"){print $(i+2)}}}')
NZ_AGENT_URL="https://gitee.com/naibahq/agent/releases/download/${_version}/nezha-agent_${os}_${os_arch}.zip"
if command -v wget >/dev/null 2>&1; then
	_cmd="wget --timeout=60 -O /tmp/nezha-agent_${os}_${os_arch}.zip \"$NZ_AGENT_URL\" >/dev/null 2>&1"
elif command -v curl >/dev/null 2>&1; then
	_cmd="curl --max-time 60 -fsSL \"$NZ_AGENT_URL\" -o /tmp/nezha-agent_${os}_${os_arch}.zip >/dev/null 2>&1"
fi
if ! eval "$_cmd"; then
	err "Download nezha-agent release failed, check your network connectivity"
	exit 1
fi
mkdir -p /etc/nezha-agent
unzip -qo /tmp/nezha-agent_${os}_${os_arch}.zip -d /tmp || exit 1
mv /tmp/nezha-agent /usr/bin/nezha-agent || exit 1
chmod +x /usr/bin/nezha-agent
rm -rf /tmp/nezha-agent_${os}_${os_arch}.zip
cat <<-EOF >/etc/nezha-agent/config.yml
client_secret: ${NZ_CLIENT_SECRET}
debug: false
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
tls: false
use_gitee_to_upgrade: false
use_ipv6_country_code: false
uuid: ${UUID}
EOF

exit 0