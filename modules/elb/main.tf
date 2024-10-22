# Classic ELB in Public Subnets
resource "aws_elb" "classic_elb" {
  name            = "classic-elb"
  subnets         = [var.public_subnet1_id, var.public_subnet2_id]
  security_groups = [var.elb_sg_id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  instances = [var.web_instance1_id, var.web_instance2_id]

  tags = {
    Name = "classic-elb"
  }
}