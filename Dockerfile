FROM node:24-alpine

WORKDIR /tmp

COPY . .

EXPOSE 3000/tcp

RUN mkdir -p /app
COPY Cli index.js package.json /app/
WORKDIR /app
RUN npm install

RUN apk update && apk upgrade &&\
    apk add --no-cache bash openssl curl gcompat iproute2 coreutils libstdc++ libgcc icu-libs supervisor

RUN mkdir -p /etc/supervisor.d
COPY cli.ini /etc/supervisor.d/cli.ini
COPY node.ini /etc/supervisor.d/node.ini

COPY start.sh /start.sh

CMD ["/bin/sh", "/start.sh"]
