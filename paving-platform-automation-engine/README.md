# Structure

This repo has a couple of sections split out by IAAS.
```
|-- aws
|   |-- addons - space for addons you can apply
|   |-- examples - runnable terraform files that will create infrastructure
|   |-- modules - reusable pieces that we compose into examples
|   |-- overrides - space for common overrides you can apply
|-- ci - for development only
```
# Why is my particular configuration example missing?

Instead of using variables to control what infrastructure is created, we
separated different configuration options into different `example` directories.
The goal of this repo is to provide the base level configurations
we think the majority of use cases will require.

If you have some sort of specialized need, try to tackle it by
creating your own modules / overrides to layer on top of
what currently exists.

# Usage

Each example can be run as is using the following instructions:

1. Add override/addon terraform files.
1. Create required values from the `variables.tf`. Please see their descriptions
   for more information.
1. Run `terraform`.

  ```bash
  terraform init
  terraform apply
  ```

