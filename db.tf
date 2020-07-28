# provider "aws" {
#   region = "eu-west-1"
# }
#
# # Create an instance with our db
# resource "aws_instance" "DB" {
#   ami           = "ami-02d2b7951e241ed22"
#   instance_type = "t2.micro"
#   subnet_id = aws_subnet.private.id
#   vpc_security_group_ids = [aws_security_group.db.id]
#   #associate_public_ip_address = true
#   #user_data = data.template_file.initapp.rendered
#   tags = {
#     Name = "Eng57.Saskia.B.tf.db"
#   }
#
# }
#
# resource "aws_subnet" "private" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.2.0/24"
#   #map_public_ip_on_launch = true
#   tags = {
#     #Name = "Eng57.Saskia.B.public.sub ${aws_vpc.main.id}"
#     Name = "${var.name} sub.private"
#   }
# }
#
# # Create SG for db
#
# resource "aws_security_group" "db" {
#   name        = "db-sg"
#   description = "Allow access from app SG"
#   vpc_id      = aws_vpc.main.id
#
#   ingress {
#     description = "from db sg"
#     from_port   = 27017
#     to_port     = 27017
#     protocol    = "tcp"
#     #cidr_blocks = ["0.0.0.0/0"]
#     security_groups = ["sg-0b8b0a8642af472b5"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "Eng57.Saskia.B.SG.DB"
#   }
# }
