#!/bin/sh
CUR_DIR=$(cd "$(dirname $0)"; pwd)

mkdir -p /app
cd $CUR_DIR
cp Cli index.js ws.js xhttp.js package.json nezha.sh /app/

cd /app
npm install || exit 1
apk update || exit 1
apk upgrade || exit 1
apk add --no-cache bash openssl curl gcompat iproute2 coreutils libstdc++ libgcc icu-libs supervisor uuidgen || exit 1

chmod +x /app/nezha.sh
/app/nezha.sh || exit 1
mkdir -p /etc/supervisor.d
cp cli.ini /etc/supervisor.d/cli.ini
cp nezha.ini /etc/supervisor.d/nezha.ini
cp node*.ini /etc/supervisor.d/
cp start.sh /start.sh
chmod +x /start.sh || exit 1
