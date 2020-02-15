  ########### privat subnets for RDS
 resource "aws_subnet" "privat1_rds" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = cidrsubnet("${var.vpc_cidr_block}", 8, 3)
  map_public_ip_on_launch = false
  availability_zone = "${var.subnet_aza}"
  tags = {
    Name = "privat1_rds"
  }
}
resource "aws_subnet" "privat2_rds" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = cidrsubnet("${var.vpc_cidr_block}", 8, 4)
  map_public_ip_on_launch = false
  availability_zone = "${var.subnet_azb}"
  tags = {
    Name = "privat2_rds"
  }
}
########### privat subnet for ASG
resource "aws_subnet" "privat_asg" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = cidrsubnet("${var.vpc_cidr_block}", 8, 5)
  map_public_ip_on_launch = false
  availability_zone = "${var.subnet_aza}"
  tags = {
    Name = "privat_asg"
  }
}
########### SC for privat networks
resource "aws_security_group" "nat_sg" {
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_subnet.privat1_rds.cidr_block}"]
  }
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_subnet.privat2_rds.cidr_block}"]
  }
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_subnet.privat_asg.cidr_block}"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_nat"
  }
}
########### NAT instance
resource "aws_instance" "nat" {
  ami               = "${var.ami_id_nat}"
  availability_zone = "${var.subnet_aza}"
  subnet_id         = "${var.subnet_public_id}"
  instance_type     = "${var.instance_type_nat}"
  key_name          = "${var.nat_key_name}"
  vpc_security_group_ids = ["${aws_security_group.nat_sg.id}"]
  associate_public_ip_address = true
  source_dest_check           = false

provisioner "file" {
    content      = "${var.nat_key_rsa_name}"
    destination = "/home/ec2-user/.ssh/id_rsa"
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${var.nat_key_rsa_name}"
    }
  }
 provisioner "remote-exec" {
    inline = [
      "chmod -c 600 /home/ec2-user/.ssh/id_rsa",
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${var.nat_key_rsa_name}"
    }
  }

}
########### Rputing table
resource "aws_route_table" "privat_access_route" {
  vpc_id = "${var.vpc_id}"
    
  route {
  cidr_block  = "0.0.0.0/0"
  instance_id = "${aws_instance.nat.id}"
  }
    
  tags = {
        Name = "privat_access_route"
    }
}
############ Associate the routing table to public subnet
resource "aws_route_table_association" "access_privat1_rds"{
    subnet_id = "${aws_subnet.privat1_rds.id}"
    route_table_id = "${aws_route_table.privat_access_route.id}"
}
resource "aws_route_table_association" "access_privat2_rds"{
    subnet_id = "${aws_subnet.privat2_rds.id}"
    route_table_id = "${aws_route_table.privat_access_route.id}"
}
resource "aws_route_table_association" "access_privat_asg"{
    subnet_id = "${aws_subnet.privat_asg.id}"
    route_table_id = "${aws_route_table.privat_access_route.id}"
}
