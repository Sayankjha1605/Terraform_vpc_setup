#vpc

resource "aws_vpc" "sayankvpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "sayankvpc"
  }
}


# public subnet

resource "aws_subnet" "sayankpublicsubnet" {
  vpc_id     = aws_vpc.sayankvpc.id
  cidr_block = "160.160.1.0/24" 

  tags = {
    Name = "sayankpublicsubnet"
  }
}



# ing

resource "aws_internet_gateway" "sayankgw" {
  vpc_id = aws_vpc.sayankvpc.id

  tags = {
    Name = "sayankgw"
  }
}


#subnet-association

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sayankpublicsubnet.id
  route_table_id = aws_route_table.sayankroute.id
}


#route

resource "aws_route_table" "sayankroute" {
  vpc_id = aws_vpc.sayankvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sayankgw.id
  }
  tags = {
    Name = "sayankroute"
  }
}



# private subnet

resource "aws_subnet" "sayankpvtsubnet" {
  vpc_id     = aws_vpc.sayankvpc.id
  cidr_block = "160.160.2.0/24"

  tags = {
    Name = "sayankpvtsubnet"
  }
}


# Elastic iP

resource "aws_eip" "lb" {
  vpc = true
}


# nat gateway

resource "aws_nat_gateway" "sayanknatgw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.sayankpvtsubnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.sayankgw]
}



# private route

resource "aws_route_table" "sayankpvtroute" {
  vpc_id = aws_vpc.sayankvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sayankgw.id
  }
  tags = {
    Name = "sayankroute"
  }
}

# private subnet-association

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sayankpvtsubnet.id
  route_table_id = aws_route_table.sayankpvtroute.id
}



# create securty group

resource "aws_security_group" "sayanksw" {
  name        = "sayanksw"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.sayankvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.sayankvpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


# create dynamic inbound rules 

  # inbond rules = [22,80,443,8080,3389,3306]

  # dynamic "ingress" {
  #   for_each = inbound rules
  #   content {
  #     from_port = inbound.values
  #     to_port = inbound.values
  #     protocol = tcp
  #     cidr_blocks = ['0.0.0.0/0']
  #   }
  # }



  tags = {
    Name = "sayanksw"
  }
}


# create an key pair

resource "aws_key_pair" "sayankkavision" {
  key_name = "sayankkavision"
  public_key = file("${path.module}/sayankkavision.pub")
}


# create an instance

resource "aws_instance" "sayankec2" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  key_name                    = "sayankkavision"
  subnet_id                   = aws_subnet.sayankpublicsubnet.id
  vpc_security_group_ids      = [aws_security_group.sayanksw.id]
  associate_public_ip_address = true
 
#  save public ip to public_ip.txt
 
  # provisioner "local_exec" {
  #   cmd = "aws_instance.sayankec2.public_ip" > public_ip.txt
  #   when = "apply" 
  #   cmd  = echo ${aws_instance.sayankec2.public_ip} >> public_ip.txt
  # }

# destroy public ip file 

#   provisioner "local_exec" {
#     when = "destroy"
#     cmd = "rm public_ip.txt"
#   }

  # Other required parameters

  tags = {
    Name = "sayankec2"
  }

}






