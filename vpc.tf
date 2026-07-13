###vpc roboshop-dev
resource "aws_vpc" "main" {
    cidr_block = var.cidr_block
    instance_tenancy = "default"
    enable_dns_hostnames = "true"

    tags = merge(
        var.vpc_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
    )
}

## create IGW roboshop-dev

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id # association with VPC
    tags = merge(
      var.igw_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
    )
}

## create 2-public subnets

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]  ## execiute 2 subnets

  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    }
  )
}

## create 2-private subnets

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
    }
  )
}
## create 2-database subnets

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]  ## execiute 2 subnets
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true


  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
    }
  )
}

### (aws eip terraform - elastic ip) creattion

resource "aws_eip" "nat" {
  domain   = "vpc"
  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    }
  )
}
## create NAT Gateway

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.nat_gateway_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }

  )
 # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}
