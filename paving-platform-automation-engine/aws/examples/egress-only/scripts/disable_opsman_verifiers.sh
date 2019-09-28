#!/bin/bash -exu

OPS_MAN_FQDN=$(terraform output ops_manager_dns)

function disable_verifiers {
  local verifiers=("AvailabilityZonesVerifier" "IaasConfigurationVerifier" "NetworksExistenceVerifier")

  uaac target https://${OPS_MAN_FQDN}/uaa --skip-ssl-validation
  uaac token owner get opsman "${OM_USERNAME}" -s "" -p "${OM_PASSWORD}"
  local uaa_access_token="$(uaac contexts | grep access_token | yq -r .access_token)"

  for verifier in "${verifiers[@]}"; do
    curl "https://${OPS_MAN_FQDN}/api/v0/staged/director/verifiers/install_time/${verifier}" \
      -X PUT \
      -H "Authorization: Bearer ${uaa_access_token}" \
      -H "Content-Type: application/json" \
      -d '{ "enabled": false }' \
      -k
    echo ""
  done

  echo "Verifier status:"
  curl "https://${OPS_MAN_FQDN}/api/v0/staged/director/verifiers/install_time" \
   -X GET -k \
   -H "Authorization: Bearer ${uaa_access_token}" | jq .
}

function main() {
  disable_verifiers
}

main "$@"
