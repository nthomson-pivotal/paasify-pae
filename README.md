# paasify-pae

This repository contains a set of Terraform configuration that can be used to quickly bootstrap an installation of Pivotal Platform Automation Engine. Currently only AWS is supported but this will expand as the support for other public clouds is added to the core `paving-platform-automation-engine` configuration by Pivotal engineering.

During an installation, the configuration in this project will:
- Pave the IaaS with the core `paving-platform-automation-engine` Terraform modules
- Provision LetsEncrypt certificates for the appropriate domains
- Configure and install the OpsManager director
- Stage and and configure the Platform Automation Engine tile
- Do a final "Apply Changes" to complete the installation

The only local prerequisite is Terraform 0.12, as all other operations are executed on a remote staging jumpbox that is built as part of the installation. This means the download and upload of tiles is quicker, and is not limited by the network connectivity of the machine on which the Terraform is executed.

## Usage

## Cleaning Up

The Terraform configuration has been deliberately structured such that a `terraform destroy` will cleanly remove all resources that were created, including any VMs provisioned by BOSH that Terraform is not directly aware of. As such, to clean up an installation simply run:

```
terraform destroy
```