resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane"))
}

resource "aws_security_group" "vms_security_group" {
  name        = "vms"
  description = "VMs Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    cidr_blocks = [var.vpc_cidr]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane-vms"))
}
