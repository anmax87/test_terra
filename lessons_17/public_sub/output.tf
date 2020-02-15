output "publuc_id" {
  value = "${aws_subnet.public1_alb.id}"
}
output "publuc1_id" {
  value = "${aws_subnet.public2_alb.id}"
}
output "aza" {
  value = "${var.subnet_aza}"
}
output "azb" {
  value = "${var.subnet_azb}"
}
output "eip" {
  value = "${aws_eip.eip.public_ip}"
}
output "privat1_alb" {
  value = "${aws_subnet.public1_alb.cidr_block}"
}
output "privat2_alb" {
  value = "${aws_subnet.public1_alb.cidr_block}"
}