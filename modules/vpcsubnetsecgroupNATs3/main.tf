data "aws_availability_zones" "azs" {
  state = "available"  
}

resource "aws_vpc" "data_vpc" {
  cidr_block = "10.0.0.0/16"

  
  tags = {
    "Project" = local.prefix,
    "Name"="data_vpc"
  }


}

resource "aws_subnet" "data_pub_subnet_az1" {
  
  vpc_id     = aws_vpc.data_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block = "10.0.1.0/24"
  tags = {
    "project" = local.prefix
  }
  
}

resource "aws_subnet" "data_pub_subnet_az2" {
  
  vpc_id     = aws_vpc.data_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block = "10.0.2.0/24"
  tags = {
    "project" = local.prefix
  }
  
}



resource "aws_subnet" "data_priv_subnet_az1" {
  vpc_id     = aws_vpc.data_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block = "10.0.3.0/24"
  tags = {
    "project" = local.prefix
  }

}

resource "aws_subnet" "data_priv_subnet_az2" {
  vpc_id     = aws_vpc.data_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block = "10.0.4.0/24"
  tags = {
    "project" = local.prefix
  }

}

resource "aws_s3_bucket" "data_bucket" {
  bucket_prefix =  "aps-data-bucket-2025"
  
}

resource "aws_instance" "data_instance" {
  ami = "ami-00c257e12d6828491"
  subnet_id = aws_subnet.data_priv_subnet_az1.id
  instance_type = "t2.micro"
}

resource "aws_instance" "public_instance" {
  ami = "ami-00c257e12d6828491"
  subnet_id = aws_subnet.data_pub_subnet_az2.id
  instance_type = "t2.micro"
}

resource "aws_internet_gateway" "data_igw" {
  vpc_id = aws_vpc.data_vpc.id

}

resource "aws_route_table" "data_public_route_table" {

  vpc_id = aws_vpc.data_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.data_igw.id
    
  }

  
}

resource "aws_route_table_association" "public_rt_assoc_az1" {
  route_table_id = aws_route_table.data_public_route_table.id
  subnet_id = aws_subnet.data_pub_subnet_az1.id
}

resource "aws_route_table_association" "public_rt_assoc_az2" {
  route_table_id = aws_route_table.data_public_route_table.id
  subnet_id = aws_subnet.data_pub_subnet_az2.id
}

resource "aws_eip" "nat_eip" {

}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.data_pub_subnet_az1.id
  
}

resource "aws_route_table" "private_route_table" {

  vpc_id = aws_vpc.data_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  
}

resource "aws_route_table_association" "private_assoc_az1" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.data_priv_subnet_az1.id
  
}

resource "aws_route_table_association" "private_assoc_az2" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.data_priv_subnet_az2.id
  
}



