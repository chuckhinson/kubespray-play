output "controller_instance_profile_name" {
  value = aws_iam_instance_profile.controller_instance_profile.name
}

output "worker_instance_profile_name" {
  value = aws_iam_instance_profile.worker_instance_profile.name
}
