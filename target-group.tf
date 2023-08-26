# Creates the application target group
resource "aws_lb_target_group" "app" {
  name     = "${var.COMPONENT}-${var.ENV}"
  port     = var.APP_PORT
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.VPC_ID

  health_check {
    path = "/health"
    healthy_threshold = 3
    unhealthy_threshold = 2 
    timeout = 3
    interval = 6
  }

}

# Attach instances to the target group 
resource "aws_lb_target_group_attachment" "instances-attach" {
  count            =  var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = element(local.ALL_INSTANCE_IDS, count.index)
  port             = var.APP_PORT
}

# Generates random number in the range of 100 to 999, which we use to assign a unique priority to the Listener rules
resource "random_integer" "priority" {
  min = 101
  max = 999
}

# Adding Rule inside the created private listerer
resource "aws_lb_listener_rule" "app-rule" {
  count        = var.LB_TYPE == "internal" ? 1 : 0
  listener_arn = data.terraform_remote_state.alb.outputs.PRIVATE_LISTENER_ARN
  priority     = random_integer.priority.result   # No two rules should have same priority, hence using the randomly created unique priority number

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    host_header {
      values = ["${var.COMPONENT}-${var.ENV}.${data.terraform_remote_state.vpc.outputs.PRIVATE_HOSTED_ZONENAME}"]
    }
  }
}


# Creating a listener in the public-alb 
resource "aws_lb_listener" "public-alb-listener" {
  count             = var.LB_TYPE == "internal" ? 0 : 1
  load_balancer_arn = data.terraform_remote_state.alb.outputs.PUBLIC_ALB_ARN
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}