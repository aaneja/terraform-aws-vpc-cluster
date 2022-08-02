output "coordinator_conn_string" {
  description = "Conn string to the coordinator"
  value       = "ssh -i ${module.ssh-key.key_name}.pem ec2-user@${module.ec2.coordinator_public_ip}"
}
