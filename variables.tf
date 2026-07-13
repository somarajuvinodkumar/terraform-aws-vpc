variable "project" {
    type = string
}
variable "environment" {
    type = string
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}
variable "vpc_tags" {
    type = map(string)
    default = {}

}

variable "igw_tags" {
    type = map(string)
    default = {}

}

variable "public_subnet_cidrs" {
    type = list(string)

}

variable "public_subnet_tags" {
    type = map(string)
    default = {}

}

variable "private_subnet_cidrs" {
    type = list(string)

}

variable "private_subnet_tags" {
    type = map(string)
    default = {}

}

variable  "database_subnet_cidrs" {
    type = list(string)
    
}
variable "database_subnet_tags" {
    type = map(string)
    default = {}

}

variable "eip_tags" {
    type = map(string)
    default = {}
}
## create NAT Gateway

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.example.id

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
