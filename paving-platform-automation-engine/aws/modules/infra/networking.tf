# Bosh Director Subnet
resource "aws_subnet" "infrastructure_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(local.infrastructure_cidr, 2, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane-infra"))
}

data "template_file" "infrastructure_subnet_gateways" {
  # Render the template once for each availability zone
  count    = length(var.availability_zones)
  template = "$${gateway}"

  vars = {
    gateway = cidrhost(element(aws_subnet.infrastructure_subnets.*.cidr_block, count.index), 1)
  }
}

resource "aws_route_table_association" "route_infrastructure_subnets" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.infrastructure_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.deployment.*.id, count.index)
}

# Ops Manager Subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane"))
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane"))
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(local.public_cidr, 2, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane-public"))
}

resource "aws_route_table_association" "route_public_subnets" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}
