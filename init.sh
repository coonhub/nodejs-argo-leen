#!/bin/sh
CUR_DIR=$(cd "$(dirname $0)"; pwd)

mkdir -p /app
cp $CUR_DIR/Cli $CUR_DIR/index.js $CUR_DIR/ws.js $CUR_DIR/xhttp.js $CUR_DIR/package.json $CUR_DIR/nezha.sh /app/
apk update || exit 1
apk upgrade || exit 1
apk add --no-cache bash openssl curl gcompat iproute2 coreutils libstdc++ libgcc icu-libs supervisor uuidgen || exit 1
chmod +x $CUR_DIR/nezha.sh
$CUR_DIR/nezha.sh || exit 1

mkdir -p /etc/supervisor.d
cp $CUR_DIR/cli.ini /etc/supervisor.d/cli.ini
cp $CUR_DIR/nezha.ini /etc/supervisor.d/nezha.ini
cp $CUR_DIR/node*.ini /etc/supervisor.d/
cp $CUR_DIR/start.sh /start.sh
chmod +x /start.sh || exit 1

cd /app
npm install || exit 1
exit 0