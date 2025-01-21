resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "VPC-1"
  }
}

resource "aws_vpc" "vpc_2" {
  cidr_block = "10.1.0.0/16"

  tags = {
    "Name" = "VPC-2"
  }
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.vpc_1.id
  peer_vpc_id   = aws_vpc.vpc_2.id
  auto_accept   = true # Automatically accepts the peering request

  tags = {
    "Name" = "VPC-1-to-VPC-2"
  }
}
resource "aws_route_table" "vpc_1_rt" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = aws_vpc.vpc_2.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    "Name" = "VPC-1-RouteTable"
  }
}
resource "aws_route_table" "vpc_2_rt" {
  vpc_id = aws_vpc.vpc_2.id

  route {
    cidr_block = aws_vpc.vpc_1.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    "Name" = "VPC-2-RouteTable"
  }
}
#TODO create VPC subnets before below

resource "aws_route_table_association" "vpc_1_rt_assoc" {
  subnet_id      = aws_subnet.vpc_1_subnet.id
  route_table_id = aws_route_table.vpc_1_rt.id
}

resource "aws_route_table_association" "vpc_2_rt_assoc" {
  subnet_id      = aws_subnet.vpc_2_subnet.id
  route_table_id = aws_route_table.vpc_2_rt.id
}
