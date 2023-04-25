FROM alpine

RUN apk add --no-cache bash curl iproute2 keepalived jq

COPY rootfs /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["keepalived", "-l", "-n", "-D", "-f", "/etc/keepalived/keepalived.conf"]
