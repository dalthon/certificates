FROM alpine

RUN apk add --no-cache gettext make openssl \
 && addgroup -S user -g 1000 && adduser -S user -u 1000 -G user

USER user

WORKDIR /certificates

COPY --chown=user:user Makefile csr.conf.template /certificates

CMD ["make", "certificate"]
