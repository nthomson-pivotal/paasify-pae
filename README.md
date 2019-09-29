# paasify-pae

This repository contains a set of Terraform configuration that can be used to quickly bootstrap an installation of Pivotal Platform Automation Engine. Currently only AWS is supported but this will expand as the support for other public clouds is added to the core `paving-platform-automation-engine` configuration by Pivotal engineering.

During an installation, the configuration in this project will:
- Pave the IaaS with the core `paving-platform-automation-engine` Terraform modules
- Provision LetsEncrypt certificates for the appropriate domains
- Configure and install the OpsManager director
- Stage and and configure the Platform Automation Engine tile
- Do a final "Apply Changes" to complete the installation

The only local prerequisite is Terraform 0.12, as all other operations are executed on a remote staging jumpbox that is built as part of the installation. This means the download and upload of tiles is quicker, and is not limited by the network connectivity of the machine on which the Terraform is executed.

## Quick Start

You must have Terraform 0.12 installed to proceed.

Create a file named `main.tf` with the following contents:

```
module "paasify" {
  source       = "github.com/nthomson-pivotal/paasify-pae/aws"

  env_name           = "cp"   # Name your environment, but try to keep it short
  dns_suffix         = "<fill>" # An existing Route53 hosted zone domain
  pivnet_token       = "<fill>" # Your Pivotal Network API token

  region             = "us-west-2"   # Pick an AWS region
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]  # Pick AZs within the above region
}

# Do not modify below here
output "opsman_url" {
  value = "https://${module.paasify.opsman_host}"
}

output "opsman_username" {
  value = module.paasify.opsman_username
}

output "opsman_password" {
  value = module.paasify.opsman_password
}

output "cp_url" {
  value = "https://${module.paasify.control_plane_domain}"
}

output "cp_username" {
  value = module.paasify.control_plane_username
}

output "cp_password" {
  value = module.paasify.control_plane_password
}
```

Import the required Terraform modules by running:

```
terraform init
```

Now generate a plan to get an idea that things will work as intended;

```
terraform plan
```

Finally, apply the configuration to build the system:

```
terraform apply
```

The build will take about 30 minutes to complete. When complete, the Terraform outputs will contain details to access the environment, for example:

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

cp_password = lDsNGhDG
cp_url = https://plane.cp.aws.paasify.org
cp_username = admin
opsman_password = XiI9J98t
opsman_url = https://pcf.cp.aws.paasify.org
opsman_username = admin
```

You can access the `cp_url` URL in your browser to login to Concourse, using `cp_username` and `cp_password` as the credentials.

## Cleaning Up

The Terraform configuration has been deliberately structured such that a `terraform destroy` will cleanly remove all resources that were created, including any VMs provisioned by BOSH that Terraform is not directly aware of. As such, to clean up an installation simply run:

```
terraform destroy
```
