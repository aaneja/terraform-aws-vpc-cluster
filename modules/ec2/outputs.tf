output "public_ip" {
  value = aws_instance.ec2_public.public_ip
}

output "coordinator_private_ip" {
  value = aws_instance.ec2_public.private_ip
}


output "private_ip" {
  value = aws_instance.ec2_private.*.private_ip
}