provider "aws" {
  region = "us-east-2"

}
resource "aws_instance" "web_server" {
  ami           = "ami-0e5497a77ef21b5ac"
  instance_type = "t3.micro"
  tags = {
    Name = "terraform-instance"
  }

}