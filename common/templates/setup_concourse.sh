#!/bin/bash

set -e

# Install credhub CLI

wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.5.3/credhub-linux-2.5.3.tgz

tar zxf credhub-linux-2.5.3.tgz

sudo mv credhub /usr/local/bin/credhub
sudo chmod +x /usr/local/bin/credhub

credhub_url=${credhub_url}

cat <<EOF > ~/credhub-ca-cert.pem
${credhub_ca_cert}
EOF

credhub_client=$(om credentials -p control-plane -c .uaa.credhub_admin_client_credentials -t json | jq -r '.identity')
credhub_secret=$(om credentials -p control-plane -c .uaa.credhub_admin_client_credentials -t json | jq -r '.password')

credhub login --client-name $credhub_client --client-secret $credhub_secret -s $credhub_url --ca-cert /home/ubuntu/credhub-ca-cert.pem

# Add credhub URL and creds to itself
credhub set -n /concourse/main/credhub_url -t value -v $credhub_url
credhub set -n /concourse/main/credhub_client -t user -z $credhub_client -w $credhub_secret