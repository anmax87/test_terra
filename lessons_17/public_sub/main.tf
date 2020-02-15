 ########### publick subnets for ALB
 resource "aws_subnet" "public1_alb" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = cidrsubnet("${var.vpc_cidr_block}", 8, 1)
  map_public_ip_on_launch = true
  availability_zone = "${var.subnet_aza}"
  tags = {
    Name = "public1_alb"
  }
}
resource "aws_subnet" "public2_alb" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = cidrsubnet("${var.vpc_cidr_block}", 8, 2)
  map_public_ip_on_launch = true
  availability_zone = "${var.subnet_azb}"
  tags = {
    Name = "public2_alb"
  }
}
########### internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"
  tags = {
    Name = "igw"
  }
}
########### Elastic IP
resource "aws_eip" "eip" {
    vpc         = true
}
########### Rputing table
resource "aws_route_table" "internet_access_route" {
  vpc_id = "${var.vpc_id}"
    
  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
        Name = "internet_access_route"
    }
  depends_on = ["aws_internet_gateway.igw", "aws_route_table.internet_access_route"]
}
############ Associate the routing table to public subnet
resource "aws_route_table_association" "internet_access_public1_alb"{
    subnet_id = "${aws_subnet.public1_alb.id}"
    route_table_id = "${aws_route_table.internet_access_route.id}"
}
resource "aws_route_table_association" "internet_access_public2_alb"{
    subnet_id = "${aws_subnet.public2_alb.id}"
    route_table_id = "${aws_route_table.internet_access_route.id}"
}  