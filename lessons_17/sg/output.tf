 output "rds_sg_id" {
  value = "${aws_security_group.rds.id}"
}

output "asg_sg_id" {
  value = "${aws_security_group.asg.id}"
}
output "public_id" {
  value = "${aws_security_group.public.id}"
}