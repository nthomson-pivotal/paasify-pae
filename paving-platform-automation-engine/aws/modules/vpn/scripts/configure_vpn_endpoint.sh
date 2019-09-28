#!/bin/bash -exu

CERT_DIR="mutual_auth"
client_config="client-config.ovpn"

function setup_prereq() {
  apk --update add python py-pip
  pip install awscli --upgrade --user
  export PATH=$PATH:/root/.local/bin
}

function authorize_ingress() {
  for cidr_to_authorize in $CIDRS_TO_AUTHORIZE; do
    aws ec2 authorize-client-vpn-ingress \
      --client-vpn-endpoint-id "${VPN_ENDPOINT_ID}" \
      --target-network-cidr "${cidr_to_authorize}" \
      --client-token "${VPN_ENDPOINT_ID}-${cidr_to_authorize}" \
      --authorize-all-groups
  done
}

function apply_security_groups() {
  aws ec2 apply-security-groups-to-client-vpn-target-network \
    --client-vpn-endpoint-id "${VPN_ENDPOINT_ID}" \
    --vpc-id "${VPC_ID}" \
    --security-group-ids "${SECURITY_GROUP_ID}"
}

function download_client_vpn_endpoint_config() {
  aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id "${VPN_ENDPOINT_ID}" --output text > ${client_config}
}

function edit_config() {
  # Append lines form client cert and key
  cat <<EOF >> ${client_config}

cert ${CERT_DIR}/client.${ROOT_DOMAIN}.crt
key ${CERT_DIR}/client.${ROOT_DOMAIN}.key
EOF

  # Prepend a random string to the Client VPN endpoint DNS name
  sed -i'' -e "s/${VPN_ENDPOINT_ID}/random_string.${VPN_ENDPOINT_ID}/g" ${client_config}
}

function main() {
  setup_prereq
  authorize_ingress
  apply_security_groups
  download_client_vpn_endpoint_config
  edit_config
}

main "$@"
