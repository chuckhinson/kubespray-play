output "elb_dns_name" {
  value = aws_lb.cluster-api.dns_name
}

output "jumpbox_public_ip" {
  value = module.vpc.jumpbox_public_ip
}

output "all_nodes" {
  value = <<EOT
%{ for controller in module.cluster.controllers ~}
${controller.private_dns}  ansible_host=${controller.private_ip}
%{ endfor ~}
%{ for worker in module.cluster.workers ~}
${worker.private_dns}  ansible_host=${worker.private_ip}
%{ endfor ~}
EOT
}

output "controller_nodes" {
  value = <<EOT
%{ for controller in module.cluster.controllers ~}
${controller.private_dns}
%{ endfor ~}
EOT
}

output "worker_nodes" {
  value = <<EOT
%{ for worker in module.cluster.workers ~}
${worker.private_dns}
%{ endfor ~}
EOT
}

