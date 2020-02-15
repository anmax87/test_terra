################ Create AWS ALB
resource "aws_lb" "alb" {
    security_groups     = ["${var.alb_sg_id}"]
    subnets             = ["${var.subnet_alb1_id}", "${var.subnet_alb2_id}"]
    internal            = false

    enable_deletion_protection  = false
    load_balancer_type          = "application"

    lifecycle {
        create_before_destroy = true
    }

    tags = {
        Name = "pub_alb"
    }
}
############## Create AWS LB target group
resource "aws_lb_target_group" "alb_tg" {
    port                 = 80
    protocol             = "HTTP"
    vpc_id               = "${var.vpc_id}"
#    target_type          = "ip"
    deregistration_delay = 300

    tags = {
        Name = "alb-tg"
    }

    health_check {
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-299"
    }
    stickiness {
        type            = "lb_cookie"
        cookie_duration = 1
        
    }
}
################# Create AWS LB listeners
resource "aws_lb_listener" "frontend_http" {

    load_balancer_arn   = "${aws_lb.alb.arn}"
    port                = "80"
    protocol            = "HTTP"

    default_action {
        target_group_arn    = "${aws_lb_target_group.alb_tg.arn}"
        type                = "forward"
    }

    depends_on = ["aws_lb.alb","aws_lb_target_group.alb_tg"]
}
############### Create AWS LB target group attachment
resource "aws_autoscaling_attachment" "asg_attachment" {

    alb_target_group_arn   = "${aws_lb_target_group.alb_tg.arn}"
    autoscaling_group_name = "${var.asg_name}"

    depends_on = ["aws_lb.alb","aws_lb_target_group.alb_tg"]
}

