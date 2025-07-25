# creating an aws resource load balancer for production servers to distrubute the traffic 
#among instances and the load balancer is in default avalibiility zones(AZ's) given by subnet attribute

resource "aws_lb" "prod-load-balancer" {
   name = "prod-load-balancer"
   load_balancer_type = "application"
   internal = false 
   ip_address_type = "ipv4"
   security_groups = [ aws_security_group.prod-sg.id ]
   subnets = data.aws_subnets.default.ids
}
# Defining the target groups that will be managed by the load balancer including health checks
resource "aws_lb_target_group" "blue-tg" {
  name = "blue-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

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
  vpc_id = data.aws_vpc.default.id
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
# group sepecified in the default action and is connected to the load balancer 

resource "aws_lb_listener" "name" {
 load_balancer_arn = aws_lb.prod-load-balancer.arn
 port = 80
 protocol = "HTTP"
 default_action {
   type = "forward"
   target_group_arn = aws_lb_target_group.blue-tg.arn
 }
}

#Assigning Servers to the target groups 
# Blue server in blue target group
resource "aws_lb_target_group_attachment" "blue_attachment" { 
  target_group_arn = aws_lb_target_group.blue-tg.arn
  target_id = aws_instance.blue-server.id
  port = 80
}
#Green Server in green target group
resource "aws_lb_target_group_attachment" "green_attachment" {
  target_id = aws_instance.green-server.id
  target_group_arn = aws_lb_target_group.green-tg.arn
  port = 80
}
