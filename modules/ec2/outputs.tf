output "coordinator_public_ip" {
  value = aws_instance.coordinator.public_ip
}


output "worker_public_ip" {
  value = aws_instance.worker.*.private_ip
}