output "blue_server_ip" {
  description = "Ip address of blue server"
  value = aws_instance.Blue_Server.public_ip
}