# FROM node:24-alpine
FROM node:24-trixie-slim

WORKDIR /tmp

COPY . .

EXPOSE 3000/tcp

RUN mkdir -p /app
COPY cli hg pc index.js ws.js xhttp.js package.json nezha.sh /app/
WORKDIR /app
RUN npm install

# RUN apk update && apk upgrade &&\
#     apk add --no-cache bash openssl curl gcompat iproute2 coreutils libstdc++ libgcc icu-libs supervisor uuidgen
RUN apt-get update && apt-get install -y curl supervisor unzip
COPY lib/* /lib/

RUN ls -1 /app/
RUN chmod +x /app/nezha.sh
RUN /app/nezha.sh

RUN mkdir -p /etc/supervisor.d
# COPY cli.ini /etc/supervisor.d/cli.ini
# COPY nezha.ini /etc/supervisor.d/nezha.ini
# COPY node*.ini /etc/supervisor.d/
COPY cli.conf /etc/supervisor/conf.d/cli.conf
COPY hg.conf /etc/supervisor/conf.d/hg.conf
COPY pc.conf /etc/supervisor/conf.d/pc.conf
COPY nezha.conf /etc/supervisor/conf.d/nezha.conf
COPY node*.conf /etc/supervisor/conf.d/

COPY start.sh /start.sh

CMD ["/bin/sh", "/start.sh"]
