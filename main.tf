# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-igw"
    }
  )
}

resource "aws_nat_gateway" "public" {
  for_each = aws_eip.nat

  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-${each.key}-nat-gateway"
    }
  )
}

# NAT Gateways for Private Subnets
resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-${each.key}-nat-eip"
    }
  )
}


# Public Subnets
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-${each.key}-public-subnet"
    }
  )
}

resource "aws_route_table" "public" {
  for_each = aws_subnet.public

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-${each.key}-public-route-table"
    }
  )
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route" "public_internet_access" {
  for_each = aws_route_table.public

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


# Private Subnets
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-${each.key}-private-subnet"
    }
  )
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-${each.key}-private-route-table"
    }
  )
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route" "private_nat_gateway" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[var.nat_gateway_mapping[each.key]].id
}
