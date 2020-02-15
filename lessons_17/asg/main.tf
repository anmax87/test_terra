## AMI
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["679593333241"]
}
## Creating Launch Configuration
resource "aws_launch_configuration" "example" {
  image_id               = "${data.aws_ami.centos.id}"
  instance_type          = "${var.instance_type}"
  security_groups        = ["${var.wp_sg}"]
  key_name               = "${var.wp_key_name}"
  
  lifecycle {
    create_before_destroy = true
  }
}
## Creating AutoScaling Group
resource "aws_autoscaling_group" "wp_asg" {
  name                      = "wp_asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 3
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.example.id}"
  vpc_zone_identifier       = ["${var.subnet_asg_id}"]

  lifecycle {
    create_before_destroy = true
  }
    
  tag {
    key                 = "Name"
    value               = "wp_asg"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_policy" "wp_asg_target_tracking_policy" {
  name                      = "staging-wp_asg-target-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = "${aws_autoscaling_group.wp_asg.name}"
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "60"
  }
}
resource "null_resource" "ConfigureAnsible" {
  provisioner "local-exec" {
    command = "sleep 120;ansible-playbook -u centos --private-key=id_rsa -i ec2.py -l 'tag_Name_wp_asg' site.yml -e host=${var.bastion_ip} -e host_key=id_rsa -e web=${var.public_eip} -e db_hostname=${var.db_address}"
  }
  depends_on  = ["aws_autoscaling_group.wp_asg"]
}