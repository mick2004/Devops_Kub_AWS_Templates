resource "aws_instance" "king_instance" {
    ami           = "ami-830c94e3"
    instance_type = "t2.micro"
    tags = {
      name = "project1"
    }
  
}