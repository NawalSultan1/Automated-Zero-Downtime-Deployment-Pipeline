output "dev_server_ip" {
  description = "Ip address of dev server"
  value = aws_instance.dev_server.public_ip
}