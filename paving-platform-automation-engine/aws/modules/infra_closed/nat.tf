resource "aws_route_table" "egress_only" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane"))
}

resource "aws_security_group" "nat_security_group" {
  name        = "nat"
  description = "NAT Security Group"
  vpc_id      = aws_vpc.vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane-nat"))
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane"))
}

resource "aws_eip" "nat_eip" {
  vpc = true

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane-nat"))
}

resource "aws_route" "internet" {
  count = length(var.availability_zones)

  route_table_id         = element(aws_route_table.egress_only.*.id, count.index)
  nat_gateway_id         = aws_nat_gateway.nat.id
  destination_cidr_block = "0.0.0.0/0"
}

