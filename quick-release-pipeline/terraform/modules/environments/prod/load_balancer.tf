# creating an aws resource load balancer for production servers to distrubute the traffic
#among instances and the load balancer is in default avalibiility zones(AZ's) given by subnet attribute

resource "aws_lb" "prod-load-balancer" {
   name = "prod-load-balancer"
   load_balancer_type = "application"
   internal = false 
   ip_address_type = "ipv4"
   security_groups = [ aws_security_group.prod-sg-lb.id ]
   subnets = [aws_subnet.prod-subnet-1.id , aws_subnet.prod-subnet-2.id]
}
# Defining the target groups that will be managed by the load balancer including health checks
resource "aws_lb_target_group" "blue-tg" {
  name = "blue-tg"
  port = 80
  target_type = "ip"
  protocol = "HTTP"
  vpc_id = aws_vpc.prod-vpc.id

  health_check {
    protocol = "HTTP"              #load balancer will use HTTP protocol to check the health of servers in this case
    path = "/"                     #where the service is running in this case in root directory
    matcher = "200"                # load balancer will look for a 200 response to consider the server healthy otherwise unhealthy 
    #health checking attributes
    interval = 30                  # every 30 seconds check for health of the servers
    healthy_threshold = 2          # each server should respond HTTP status code of 200 2 times in a row to be considered as healthy
    unhealthy_threshold = 2        # each server should respond HTTP status code of != 200 2 times in a row to be considered as unhealthy
    timeout = 5                    # load balancer will wait for 5 seconds for a response after that the check fails
  }
}
resource "aws_lb_target_group" "green-tg" {
  name = "green-tg"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.prod-vpc.id
  health_check {
    protocol = "HTTP"
    path = "/" 
    matcher = "200"
    healthy_threshold = 2
    interval = 30
    unhealthy_threshold = 2
    timeout = 5
  }
}
# The aws listener listens to the incoming traffic and redirects it to the target 
# group sepecified in the default action and is connected to the load balancer Like a rule book that what to do with the incoming traffic

resource "aws_lb_listener" "prod-lb-listener" {
 load_balancer_arn = aws_lb.prod-load-balancer.arn
 port = 80
 protocol = "HTTP"
 default_action {
   type = "forward"
   target_group_arn = var.live-environment == "blue" ? aws_lb_target_group.blue-tg.arn : aws_lb_target_group.green-tg.arn
 }
}


resource "aws_lb_listener_rule" "inactive_rule" {
  priority     = 100
  listener_arn = aws_lb_listener.prod-lb-listener.arn

  # The action now dynamically points to the INACTIVE target group.
  action {
    type             = "forward"
    target_group_arn = var.live-environment == "blue" ? aws_lb_target_group.green-tg.arn : aws_lb_target_group.blue-tg.arn
  }

  # The condition that will never be met by real traffic.
  condition {
    path_pattern {
      values = ["/inactive-path-for-health-check"]
    }
  }
}