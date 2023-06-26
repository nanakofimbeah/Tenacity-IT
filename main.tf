resource "aws_vpc" "tenacity-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "nakomb-vpc"
  }
}

resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = "${aws_vpc.tenacity-vpc.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod-pub-sub1"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = "${aws_vpc.tenacity-vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Prod-pub-sub2"
  }
}

resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = "${aws_vpc.tenacity-vpc.id}"
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = "${aws_vpc.tenacity-vpc.id}"
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Prod-priv-sub2"
  }
}

resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id     = "${aws_vpc.tenacity-vpc.id}"
  
  tags = {
    Name = "Prod-pub-route-table"
  }
}

resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id     = "${aws_vpc.tenacity-vpc.id}"
  
  tags = {
    Name = "Prod-pub-route-table"
  }
}

resource "aws_route_table_association" "Prod-pub-igw1-association" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Prod-pub-igw2-association" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Prod-priv-igw1-association" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_route_table_association" "Prod-priv-igw2-association" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.tenacity-vpc.id

  tags = {
    Name = "tenacity-IGW"
  }
}

resource "aws_route" "public-igw-route" {
  route_table_id            = aws_route_table.Prod-pub-route-table.id
  gateway_id                = aws_internet_gateway.Prod-igw.id
  destination_cidr_block    = "0.0.0.0/0"
}



resource "aws_eip" "Prod_nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "Prod_nat_gateway" {
  allocation_id = aws_eip.Prod_nat_gateway.id
  subnet_id = aws_subnet.Prod-pub-sub1.id
  tags = {
    "Name" = "Prod_nat_gateway"
  }
}

output "nat_gateway_ip" {
  value = aws_eip.Prod_nat_gateway.public_ip
}

resource "aws_route_table" "instance" {
  vpc_id = aws_vpc.tenacity-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Prod_nat_gateway.id
  }
}