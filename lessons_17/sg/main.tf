# Private security group RDS
resource "aws_security_group" "rds" {
  name        = "rds_sg"
  description = "Security group to access rds ports"
  vpc_id      = "${var.vpc_id}"

  # allow mysql port within VPC from public subnet
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "rds_sg"
  }
}
# Private security group ASG
resource "aws_security_group" "asg" {
  name        = "asg_sg"
  description = "Security group to access asg ports"
  vpc_id      = "${var.vpc_id}"

  # allow http port within VPC from public subnet
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
###      "${var.subnet_alb2_cidr}",
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
###      "${var.subnet_alb2_cidr}",
    ]
  }

  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "asg_sg"
  }
}
# Public security group
resource "aws_security_group" "public" {
  name        = "public"
  description = "Public access security group"
  vpc_id      = "${var.vpc_id}"

  # allow http traffic
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

#  ingress {
#    from_port = 0
#    to_port   = 0
#    protocol  = "-1"
#
#    cidr_blocks = [
#     "${var.subnet_alb1_cidr}",
#      "${var.subnet_alb2_cidr}",
#    ]
#  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "public_sg"
  }
}
