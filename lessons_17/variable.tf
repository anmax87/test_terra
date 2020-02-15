######### VPC 
variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
    description = "vpc cidr"
}
variable "vpc_name" {
  description = "VPC default"
  default     = "vpc_main"
}

########### Network
variable "subnet_public_aza" {
  description = "Availability zones for public subnet"
  default     = "us-west-2a"
}
variable "subnet_public_azb" {
  description = "Availability zones for public subnet"
  default     = "us-west-2b"
}
########### NAT
variable "ami_id_nat" {
  description = "AMI ID for nat instance (different for each region)"
  default = "ami-0b840e8a1ce4cdf15"
}

variable "instance_type_nat" {
  description = "Instance size for NAT gateway"
  default     = "t2.micro"
}
########### ASG
variable "instance_type" {
  description = "Instance size for WP instance"
  default     = "t2.micro"
}

