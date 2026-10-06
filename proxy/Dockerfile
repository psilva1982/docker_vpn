FROM alpine:3.21

RUN apk add --no-cache squid apache2-utils

COPY config/ /etc/squid/proxy/
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 3128/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
