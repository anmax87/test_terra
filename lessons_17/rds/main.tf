########### Create DB subnet
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${var.subnet_rds1_id}", "${var.subnet_rds2_id}"]

  tags = {
    Name = "My DB subnet group"
  }
} 
########### Create DB instance
resource "aws_db_instance" "default" {
  allocated_storage      = 8
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "wpdb"
  username               = "wordpress"
  password               = "wordpress"
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  vpc_security_group_ids = ["${var.rds_sg_id}"]
}