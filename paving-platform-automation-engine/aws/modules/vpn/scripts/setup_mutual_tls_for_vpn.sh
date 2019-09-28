#!/bin/bash -exu

CERT_DIR="$(pwd)/mutual_auth"

function setup_prereq() {
  apk --update add python py-pip openssl
  pip install awscli --upgrade --user
  export PATH=$PATH:/root/.local/bin
}

function generate_easyrsa_certs() {
  git clone https://github.com/OpenVPN/easy-rsa.git || true # don't fail on clone fail, if exists already
  pushd easy-rsa/easyrsa3 > /dev/null
    rm -rf pki || true # fails if the folder already exists from another run
    ./easyrsa init-pki
    ./easyrsa --batch --req-cn="${ROOT_DOMAIN}" build-ca nopass
    ./easyrsa build-server-full ${ROOT_DOMAIN} nopass
    ./easyrsa build-client-full client.${ROOT_DOMAIN} nopass
  popd
}

function import_acm_certs() {
  mkdir ${CERT_DIR} || true
  pushd easy-rsa/easyrsa3 > /dev/null
    cp pki/ca.crt ${CERT_DIR}/
    cp pki/issued/${ROOT_DOMAIN}.crt ${CERT_DIR}/
    cp pki/private/${ROOT_DOMAIN}.key ${CERT_DIR}/
    cp pki/issued/client.${ROOT_DOMAIN}.crt ${CERT_DIR}
    cp pki/private/client.${ROOT_DOMAIN}.key ${CERT_DIR}/
  popd

  pushd ${CERT_DIR} > /dev/null
    aws acm import-certificate --certificate file://${ROOT_DOMAIN}.crt --private-key file://${ROOT_DOMAIN}.key --certificate-chain file://ca.crt --region "${REGION}"
    aws acm import-certificate --certificate file://client.${ROOT_DOMAIN}.crt --private-key file://client.${ROOT_DOMAIN}.key --certificate-chain file://ca.crt --region "${REGION}"
  popd
}

function main() {
  setup_prereq
  pushd /tmp > /dev/null
    generate_easyrsa_certs
    import_acm_certs
  popd
}

main "$@"
