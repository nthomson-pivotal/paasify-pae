#!/bin/bash

set -e

# Install credhub CLI

wget -q https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.5.3/credhub-linux-2.5.3.tgz

tar zxf credhub-linux-2.5.3.tgz

sudo mv credhub /usr/local/bin/credhub
sudo chmod +x /usr/local/bin/credhub

credhub_url=${credhub_url}

cat <<EOF > ~/credhub-ca-cert.pem
${credhub_ca_cert}
EOF

credhub_client=$(om credentials -p control-plane -c .uaa.credhub_admin_client_credentials -t json | jq -r '.identity')
credhub_secret=$(om credentials -p control-plane -c .uaa.credhub_admin_client_credentials -t json | jq -r '.password')

export CREDHUB_SERVER=$credhub_url
export CREDHUB_CLIENT=$credhub_client
export CREDHUB_SECRET=$credhub_secret
export CREDHUB_CA_CERT=~/credhub-ca-cert.pem

# Add stuff to credhub
# Pivnet token
credhub set -n /concourse/main/pivnet_token -t value -v $pivnet_token

# Credhub to itself
credhub set -n /concourse/main/credhub_url -t value -v $credhub_url
credhub set -n /concourse/main/credhub_client -t user -z $credhub_client -w $credhub_secret
credhub set -n /concourse/main/credhub_ca_cert -t certificate -c $CREDHUB_CA_CERT

# Admin IAM
credhub set -n /concourse/main/admin_access_key_id -t value -v $admin_access_key_id
credhub set -n /concourse/main/admin_secret_access_key -t value -v $admin_secret_access_key

# S3 buckets
credhub set -n /concourse/main/s3_access_key_id -t value -v $control_plane_s3_access_key_id
credhub set -n /concourse/main/s3_secret_access_key -t value -v $control_plane_s3_secret_access_key

credhub set -n /concourse/main/s3_endpoint -t value -v $control_plane_s3_endpoint
credhub set -n /concourse/main/s3_region -t value -v $control_plane_s3_region

credhub set -n /concourse/main/s3_artifact_bucket -t value -v $control_plane_s3_artifact_bucket
credhub set -n /concourse/main/s3_exports_bucket -t value -v $control_plane_s3_exports_bucket

if [ ! -z $git_private_key ]; then
  credhub set -n /concourse/main/git_private_key -t ssh -p "$git_private_key"
fi