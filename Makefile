ROOT_FOLDER ?= `pwd`

ROOT_CA_FOLDER ?= certificate_authorities
ROOT_CA_NAME ?= root_ca
ROOT_CA_CN_NAME ?= $(ROOT_CA_NAME)
ROOT_CA_SUBJ := "/CN=$(ROOT_CA_CN_NAME)/O=$(ROOT_CA_CN_NAME)"

CERTIFICATE_FOLDER ?= certificates
CERTIFICATE_EXPIRATION ?= 3650

default: certificate_authority

.PHONY: certificate_authority
certificate_authority:
	make $(ROOT_CA_FOLDER)/$(ROOT_CA_NAME).crt

$(ROOT_CA_FOLDER):
	mkdir -p $@

$(ROOT_CA_FOLDER)/$(ROOT_CA_NAME).key: $(ROOT_CA_FOLDER)
	openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out $@

$(ROOT_CA_FOLDER)/%.crt: $(ROOT_CA_FOLDER)/%.key
	openssl req -x509 -key $< -out $@ -subj $(ROOT_CA_SUBJ)

.PHONY: certificate-%
certificate-%:
	make $(CERTIFICATE_FOLDER)/$*.crt $(CERTIFICATE_FOLDER)/$*.key

$(CERTIFICATE_FOLDER):
	mkdir -p $@

$(CERTIFICATE_FOLDER)/%.key: $(CERTIFICATE_FOLDER)
	openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out $@

$(CERTIFICATE_FOLDER)/%.conf:
	cat csr.conf.template | DOMAIN=$* ORG_NAME=$${ORG_NAME:-$*} envsubst > $@

$(CERTIFICATE_FOLDER)/%.csr: $(CERTIFICATE_FOLDER)/%.key $(CERTIFICATE_FOLDER)/%.conf
	openssl req -new -key $< -out $@ -config $(CERTIFICATE_FOLDER)/$*.conf

$(CERTIFICATE_FOLDER)/%.crt: $(CERTIFICATE_FOLDER)/%.csr $(ROOT_CA_FOLDER)/$(ROOT_CA_NAME).crt
	openssl x509 -req \
	  -days $(CERTIFICATE_EXPIRATION) \
	  -extensions req_ext \
	  -extfile $(CERTIFICATE_FOLDER)/$*.conf \
	  -CA $(ROOT_CA_FOLDER)/$(ROOT_CA_NAME).crt \
	  -CAkey $(ROOT_CA_FOLDER)/$(ROOT_CA_NAME).key \
	  -in $< \
	  -out $@

.PHONY: build
build:
	docker build -t dalthon/certificates .

.PHONY: shell
shell:
	docker run --rm -it \
		-v $(ROOT_FOLDER)/certificates:/certificates/certificates \
		-v $(ROOT_FOLDER)/certificate_authorities:/certificates/certificate_authorities \
		dalthon/certificates ash

.PHONY: clean
clean:
	rm -rf $(ROOT_CA_FOLDER)/*.crt
	rm -rf $(ROOT_CA_FOLDER)/*.key
	rm -rf $(CERTIFICATE_FOLDER)/*.crt
	rm -rf $(CERTIFICATE_FOLDER)/*.key
