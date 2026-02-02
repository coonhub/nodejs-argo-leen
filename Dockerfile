FROM node:24-alpine

WORKDIR /tmp

COPY . .

EXPOSE 3000/tcp

RUN mkdir -p /app
COPY Cli index.js ws.js xhttp.js package.json nezha.sh /app/
WORKDIR /app
RUN npm install

RUN apk update && apk upgrade &&\
    apk add --no-cache bash openssl curl gcompat iproute2 coreutils libstdc++ libgcc icu-libs supervisor uuidgen

RUN ls -1 /app/
RUN chmod +x /app/nezha.sh
RUN /app/nezha.sh

RUN mkdir -p /etc/supervisor.d
COPY cli.ini /etc/supervisor.d/cli.ini
COPY nezha.ini /etc/supervisor.d/nezha.ini
COPY node*.ini /etc/supervisor.d/

COPY start.sh /start.sh

CMD ["/bin/sh", "/start.sh"]
