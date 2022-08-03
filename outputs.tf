output "coordinator_conn_string" {
  description = "Conn string to the coordinator"
  value       = "ssh -F ${local_file.vpc_hosts.filename} coordinator"
}

output "worker_conn_string" {
  description = "Conn string to the worker(s)"
  value       = "ssh -F ${local_file.vpc_hosts.filename} worker{0,1,..,n-1}"
}