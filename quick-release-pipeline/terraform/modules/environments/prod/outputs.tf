#use to get the public ip addresses of blue and green server to use in ansible 
output "blue_server_ip" {
  description = "Ip address of blue server"
  value = aws_instance.blue-server.public_ip
}
output "green-server-ip" {
  description = "Public ip address of green server"
  value = aws_instance.green-server.public_ip
}