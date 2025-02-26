# Certificates

Simple way to create a certificate authority key and certificates and issue
certificates signed by that.

Docker image available at [dockerhub](https://hub.docker.com/r/dalthon/certificates).

# Usage

## With docker

### To create a certificate authority and signed certificate at once

To create a certificate for `example.domain.com` with a default root
certificate authority, just run:

```sh
mkdir -p certificates
mkdir -p certificate_authorities
docker run --rm -it \
  -v `pwd`/certificates:/certificates/certificates \
  -v `pwd`/certificate_authorities:/certificates/certificate_authorities \
  dalthon/certificates certificate-example.domain.com
```

This will create a pair of `root_ca.key` and `root_ca.crt` files for the root ca at
`certificate_authorities`. To replace `root_ca` to another name, just add an
environment variable `ROOT_CA_NAME` with whatever pleases you.

Files `example.domain.com.key` and  `example.domain.com.crt` will be created at
`certificates` folder. They can be used to `example.domain.com` and its subdomains,
in other words, `*.example.domain.com`.

If run more than once, it does not recreate the certificate authority if it was
already created.

### To create a certificate authority

Just run:

```sh
mkdir -p certificates
mkdir -p certificate_authorities
docker run --rm -it \
  -v `pwd`/certificates:/certificates/certificates \
  -v `pwd`/certificate_authorities:/certificates/certificate_authorities \
  dalthon/certificates certificate_authority
```

This is like the previous example, but does not create a certificate, only
creates the authority.

## With docker compose

Just use this service:

```yaml
services:
  certificates:
    image: dalthon/certificates
    environment:
      DOMAIN:                 example.domain.com # domain to get certificate for
      ORG_NAME:               example.domain.com # [optional] identifies organization that owns the certificate, defaults to same value as domain
      CERTIFICATE_EXPIRATION: 3650               # [optional] defaults to 3650 days
      ROOT_CA_NAME:           root_ca            # [optional] defaults to root_ca
      ROOT_CA_CN_NAME:        root_ca            # [optional] defaults to same value as ROOT_CA_NAME
    volumes:
      - ./certificates:/certificates/certificates
      - ./certificate_authorities:/certificates/certificate_authorities
```

This will create a certificate authority and certificate for the given configured
domain. You don't need to worry about overwriting certificates by running this
more than once, it only creates the files if they don't exists.

There is a very nice example about how to use it with a nginx-proxy service at
`docker-compose.yml` that expose `whoami.localhost` by `https` and redirects to
`https` when any `http` request is performed.

## Cloning this repository

You need to have installed:

1. `openssl`
2. `make`
3. `envsubst`

Once you have it, to create a certificate authority run:

```sh
make certificate-example.domain.com
```

That behaves like described at docker example.

To create just the certificate authority run:

```sh
make certificate_authority
```

Check optional variables defined at `Makefile` to know what could be configured.

Also at Ubuntu, you can install the root certificate authority by running:

```sh
make install
```
