provider "aws" {
  region = "eu-west-1"
}



# Create an instance with our app
resource "aws_instance" "Web" {
  ami           = "ami-02d2b7951e241ed22"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  associate_public_ip_address = true
  user_data = data.template_file.initapp.rendered
  tags = {
    Name = "Eng57.Saskia.B.tf.app"
  }

}

# Create an instance with our db
resource "aws_instance" "DB" {
  ami           = "ami-09dfae1594679f82d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db.id]
  associate_public_ip_address = true
  #user_data = data.template_file.initapp.rendered
  tags = {
    Name = "Eng57.Saskia.B.tf.db"
  }

}

# Create a vpc
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  #instance_tenancy = "default"

  tags = {
    Name = "Eng57.Saskia.B.vpc.tf"
  }
}

# Create IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    #Name = "Eng57.Saskia.B.igw.tf"
    Name = "${var.name} igw"
  }
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    #Name = "Eng57.Saskia.B.public.sub ${aws_vpc.main.id}"
    Name = "${var.name} sub.public"
  }
}

# Create private subnet for DB

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    #Name = "Eng57.Saskia.B.public.sub ${aws_vpc.main.id}"
    Name = "${var.name} sub.private"
  }
}


# Create SG for webapp
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Allow http and https traffic"
  vpc_id      = aws_vpc.main.id

 ingress {
   description = "https from VPC"
   from_port   = 443
   to_port     = 443
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
   description = "http from VPC"
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 # ingress {
 #   description = "http from VPC"
 #   from_port   = 3000
 #   to_port     = 3000
 #   protocol    = "tcp"
 #   cidr_blocks = ["0.0.0.0/0"]
 # }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
   Name = "Eng57.Saskia.B.SG"
 }
}

# # Create SG for db
#
resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "Allow access from app SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "from db sg"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["sg-0b8b0a8642af472b5"]
  }

## to change to Public sub in 
  ingress {
    description = "Private Sub IN"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  ingress {
    description = "from db sg"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["176.151.26.19/32"]
  }

  ingress {
    description = "HTTP IN"
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
    Name = "Eng57.Saskia.B.SG.DB"
  }
}

# Create NACL for pub sub
resource "aws_network_acl" "public-nacl" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

# traffic on EPHEMERAL PORTS allows
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }


  tags = {
    Name = "Eng57.Saskia.B.pub.NACL"
  }
}

# Create NACL for private sub
resource "aws_network_acl" "private-nacl" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.private.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
   protocol   = "tcp"
   rule_no    = 110
   action     = "allow"
   cidr_block = "0.0.0.0/0"
   from_port  = 443
   to_port    = 443
 }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

# traffic on EPHEMERAL PORTS allows
  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
      protocol   = "tcp"
      rule_no    = 120
      action     = "allow"
      cidr_block = "10.0.2.0/24"
      from_port  = 27017
      to_port    = 27017
    }

  tags = {
    Name = "Eng57.Saskia.B.priv.NACL"
  }
}


# Create a route table for public subnet
resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Eng57.Saskia.B.public.route"
  }
}

# Create route table association
resource "aws_route_table_association" "Pub-Route-Association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route-public.id
}

# Create a private route table
resource "aws_route_table" "route-private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Eng57.Saskia.B.private.route"
  }
}

resource "aws_route_table_association" "Priv-Route-Association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.route-private.id
}


# launch init script to be used
data "template_file" "initapp" {
  template = file("./scripts/app/init.sh.tpl")
  vars = {
     db_host = "mongodb://${aws_instance.DB.private_ip}:27017/posts"
   }
}
