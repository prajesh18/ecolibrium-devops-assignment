resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "ecolibrium-vpc"
  }
}
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true

  availability_zone = element(
    ["ap-south-1a", "ap-south-1b"],
    count.index
  )

  tags = {
    Name = "public-subnet-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]

  availability_zone = element(
    ["ap-south-1a", "ap-south-1b"],
    count.index
  )

  tags = {
    Name = "private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecolibrium-igw"
  }
}
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "ecolibrium-nat-eip"
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "ecolibrium-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
