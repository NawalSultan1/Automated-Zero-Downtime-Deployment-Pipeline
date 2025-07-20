resource "local_file" "ansible_inventory" {
  filename = "../../../../ansible/inventory-prod" 
  content = <<EOF
  [blue]
  ${aws_instance.blue-server.public_ip}
  
  [green]
  ${aws_instance.green-server.public_ip}
  
  [all:vars]
  ansible_user=ubuntu
  ansible_private_key_file=../terraform/modules/environments/prod/blue-key 
  EOF
}