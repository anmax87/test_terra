 output "asg_name" {
  value = "${aws_autoscaling_group.wp_asg.id}"
}
