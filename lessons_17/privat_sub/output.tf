 output "id" {
  value = "${aws_instance.nat.id}"
}
output "public_ip" {
  value = "${aws_instance.nat.public_ip}"
}
output "aza" {
  value = "${var.subnet_aza}"
}
output "azb" {
  value = "${var.subnet_azb}"
}
output "privat1_rds" {
  value = "${aws_subnet.privat1_rds.cidr_block}"
}
output "privat2_rds" {
  value = "${aws_subnet.privat2_rds.cidr_block}"
}
output "privat_asg" {
  value = "${aws_subnet.privat_asg.cidr_block}"
}
output "privat_asg_sub_id" {
  value = "${aws_subnet.privat_asg.id}"
}
output "privat1_rds_id" {
  value = "${aws_subnet.privat1_rds.id}"
}
output "privat2_rds_id" {
  value = "${aws_subnet.privat2_rds.id}"
}