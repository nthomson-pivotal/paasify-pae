variable "vpc_cidr" {
  type = "string"
}

locals {
  cidr_split  = split("/", var.vpc_cidr)
  cidr_prefix = local.cidr_split[1]

  cidr_breakout_map = {
    "16" = {
      "vpn"          = 6
      "large"        = 6
      "medium"       = 8
      "small"        = 10
      "infra_index"  = 64
      "closed_index" = 72
      "vpn_index"    = 3
    }

    "20" = {
      "vpn"          = 2
      "large"        = 3
      "medium"       = 5
      "small"        = 6
      "infra_index"  = 48
      "closed_index" = 26
      "vpn_index"    = 2
    }
  }

  newbits_to_large        = lookup(local.cidr_breakout_map[local.cidr_prefix], "large")
  newbits_to_medium       = lookup(local.cidr_breakout_map[local.cidr_prefix], "medium")
  newbits_to_small        = lookup(local.cidr_breakout_map[local.cidr_prefix], "small")
  newbits_to_vpn          = lookup(local.cidr_breakout_map[local.cidr_prefix], "vpn")
  index_for_ifra_subnet   = lookup(local.cidr_breakout_map[local.cidr_prefix], "infra_index")
  index_for_closed_subnet = lookup(local.cidr_breakout_map[local.cidr_prefix], "closed_index")
  index_for_vpn_subnet    = lookup(local.cidr_breakout_map[local.cidr_prefix], "vpn_index")

  #                                                                                                          /20                /16
  public_cidr         = cidrsubnet(var.vpc_cidr, local.newbits_to_large, 0)                              # 10.0.0.0/23      10.0.0.0/22
  control_plane_cidr  = cidrsubnet(var.vpc_cidr, local.newbits_to_large, 1)                              # 10.0.2.0/23      10.0.4.0/22
  rds_cidr            = cidrsubnet(var.vpc_cidr, local.newbits_to_large, 2)                              # 10.0.4.0/23      10.0.8.0/22
  vpn_cidr            = cidrsubnet(var.vpc_cidr, local.newbits_to_vpn, local.index_for_vpn_subnet)       # 10.0.8.0/22      10.0.12.0/22 This must be a /22 or larger per AWS
  infrastructure_cidr = cidrsubnet(var.vpc_cidr, local.newbits_to_small, local.index_for_ifra_subnet)    # 10.0.12.0/26     10.0.16.0/26
  closed_cidr         = cidrsubnet(var.vpc_cidr, local.newbits_to_medium, local.index_for_closed_subnet) # 10.0.13.0/25     10.0.72.0/24
}

