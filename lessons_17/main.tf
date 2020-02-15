## Create a private/public key that'll be used for access from Bastion host/NAT Gateway
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "key_pair" {
  key_name   = "asg_public_rsa"
    public_key = "${tls_private_key.private_key.public_key_openssh}"
}
resource "aws_key_pair" "terraform_key" {
  key_name = "terraform_key"
    public_key = "${tls_private_key.private_key.public_key_openssh}"
}
## Write the private key to access bastion/asg hosts in a file
resource "local_file" "bastion_private_key_local" {
  content  = "${tls_private_key.private_key.private_key_pem}"
  filename = "${path.module}/id_rsa"
  file_permission = 0600
}

module "vpc" {
  source = "./vpc"

  vpc_name       = "${var.vpc_name}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
}

module "subnet_public" {
  source = "./public_sub"

  vpc_id         = "${module.vpc.id}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  subnet_aza     = "${var.subnet_public_aza}"
  subnet_azb     = "${var.subnet_public_azb}"
}

module "subnet_privat" {
  source = "./privat_sub"

  vpc_id            = "${module.vpc.id}"
  vpc_cidr_block    = "${var.vpc_cidr_block}"
  ami_id_nat        = "${var.ami_id_nat}"
  instance_type_nat = "${var.instance_type_nat}"
  subnet_public_id  = "${module.subnet_public.publuc_id}"
  nat_key_name      = "${aws_key_pair.terraform_key.key_name}"
  nat_key_rsa_name  = "${tls_private_key.private_key.private_key_pem}"
  subnet_aza        = "${var.subnet_public_aza}"
  subnet_azb        = "${var.subnet_public_azb}"

}
module "security_groups" {
  source = "./sg"

  vpc_id              = "${module.vpc.id}"
  subnet_rds1_cidr    = "${module.subnet_privat.privat1_rds}"
  subnet_rds2_cidr    = "${module.subnet_privat.privat2_rds}"
  subnet_asg_cidr     = "${module.subnet_privat.privat_asg}"
  subnet_alb1_cidr    = "${module.subnet_public.privat1_alb}"
  subnet_alb2_cidr    = "${module.subnet_public.privat2_alb}"
}
module "asg" {
  source = "./asg"

  vpc_id           = "${module.vpc.id}"
  instance_type    = "${var.instance_type}"
  wp_sg            = "${module.security_groups.asg_sg_id}"
  wp_key_name      = "${aws_key_pair.key_pair.key_name}"
  subnet_asg_id    = "${module.subnet_privat.privat_asg_sub_id}"
  public_eip       = "${module.subnet_public.eip}"
  bastion_ip       = "${module.subnet_privat.public_ip}"
  db_address       = "${module.rds.db_address}"
}
module "alb" {
  source = "./alb"

  vpc_id           = "${module.vpc.id}"
  alb_sg_id        = "${module.security_groups.public_id}"
  subnet_alb1_id   = "${module.subnet_public.publuc_id}"
  subnet_alb2_id   = "${module.subnet_public.publuc1_id}"
  asg_name         = "${module.asg.asg_name}"
}
module "rds" {
  source = "./rds"

  rds_sg_id       = "${module.security_groups.rds_sg_id}"
  subnet_rds1_id  = "${module.subnet_privat.privat1_rds_id}"
  subnet_rds2_id  = "${module.subnet_privat.privat2_rds_id}"
}



