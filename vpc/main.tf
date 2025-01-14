/*====
The VPC
======*/

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-${var.project}-vpc"
    Environment = "${var.environment}"
  }
}

/*====
Subnets
======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name        = "${var.environment}-${var.project}-igw"
    Environment = "${var.environment}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]

  tags = {
    Name        = "${var.environment}-${var.project}-nat"
    Environment = "${var.environment}"
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr, count.index)}"
  availability_zone       = "${element(local.availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${element(local.availability_zones, count.index)}-public-subnet"
    Environment = "${var.environment}"
    "kubernetes.io/cluster/${var.environment}-${var.project}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(local.availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-${element(local.availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
    "kubernetes.io/cluster/${var.environment}-${var.project}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name        = "${var.environment}-${var.project}-private-route-table"
    Environment = "${var.environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name        = "${var.environment}-${var.project}-public-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

/*====
VPC's Default Security Group
======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-${var.project}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]

  # Define ingress rules
  dynamic "ingress" {
    for_each = [
      {
        name        = "HTTP",
        from_port   = 80,
        to_port     = 80,
        protocol    = "TCP",
        cidr_blocks = ["0.0.0.0/0"],
        description = "Allow HTTP traffic"
      },
      {
        name        = "NFS",
        from_port   = 2049,
        to_port     = 2049,
        protocol    = "TCP",
        cidr_blocks = [var.vpc_cidr],
        description = "Allow NFS traffic within the VPC"
      },
      {
        name        = "NFS",
        from_port   = 5432,
        to_port     = 5432,
        protocol    = "TCP",
        cidr_blocks = [var.vpc_cidr],
        description = "Allow NFS traffic within the VPC"
      },
      {
        name        = "HTTPS",
        from_port   = 443,
        to_port     = 443,
        protocol    = "TCP",
        cidr_blocks = ["0.0.0.0/0"],
        description = "Allow HTTPS traffic"
      }
    ]

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      description = ingress.value.description
      cidr_blocks = can(ingress.value.cidr_blocks) ? ingress.value.cidr_blocks : null
    }
  }

# Define egress rules
  dynamic "egress" {
    for_each = [
      {
        name        = "NFS",
        from_port   = 2049,
        to_port     = 2049,
        protocol    = "TCP",
        cidr_blocks = [var.vpc_cidr],
        description = "Allow NFS traffic within the VPC"
      },
      {
        name        = "ALL",
        from_port   = 0,
        to_port     = 0,
        protocol    = "-1",
        cidr_blocks = ["0.0.0.0/0"],
        description = "Allow All traffic within the VPC"
      }
    ]

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      description = egress.value.description
      cidr_blocks = can(egress.value.cidr_blocks) ? egress.value.cidr_blocks : null
    }
  }

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "ingress_all_traffic" {
  security_group_id = aws_security_group.default.id
  type              = "ingress"
  protocol          = "-1"  # ALL protocols
  from_port         = 0     # ALL ports
  to_port           = 0     # ALL ports
  source_security_group_id = aws_security_group.default.id
}