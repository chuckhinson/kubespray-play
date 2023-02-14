output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "controller_ips" {
  value = aws_instance.controllers[*].private_ip
}

output "controllers" {
  value = aws_instance.controllers
}

output "workers" {
  value = aws_instance.workers
}
