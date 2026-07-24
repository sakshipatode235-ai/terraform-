resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_first_vpc"
  }

}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = "us-east-2a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"

  }



}
resource "aws_subnet" "private_subnet" {

  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "privat_subnet"
  }


}

resource "aws_internet_gateway" "igt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "igt"
  }

}

resource "aws_eip" "nat_ip" {
  domain = "vpc"
  tags = {
    Name = "elastic_ip"
  }

}

resource "aws_nat_gateway" "nat_gt" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.nat_ip.id
  tags = {
    Name = "nat_gt"
  }

}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igt.id
  }

}

resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gt.id
  }
}

resource "aws_route_table_association" "privat_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id

}

resource "aws_security_group" "my_sg" {
  name        = "my-security-grp"
  vpc_id      = aws_vpc.my_vpc.id
  description = "this has port 80 and 22"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "my-first-security-grp"
  }
}

resource "aws_instance" "Public_instance" {
  ami                    = "ami-078fe7ff43e10cf8c"
  instance_type          = "t3.micro"
  key_name               = "ohio"
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  subnet_id              = aws_subnet.public_subnet.id

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install nginx -y
systemctl enable nginx
systemctl start nginx
EOF

}
resource "aws_instance" "Private_instance" {
  ami                    = "ami-078fe7ff43e10cf8c"
  instance_type          = "t3.micro"
  key_name               = "ohio"
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  subnet_id              = aws_subnet.private_subnet.id
}