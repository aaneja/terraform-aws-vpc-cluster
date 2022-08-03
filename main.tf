module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "ssh-key" {
  source    = "./modules/ssh-key"
  namespace = var.namespace
}

module "ec2" {
  source                    = "./modules/ec2"
  namespace                 = var.namespace
  coordinator_instance_type = var.coordinator_instance_type
  worker_instance_type      = var.worker_instance_type
  worker_count              = var.worker_count
  vpc                       = module.networking.vpc
  sg_pub_id                 = module.networking.sg_pub_id
  sg_priv_id                = module.networking.sg_priv_id
  key_name                  = module.ssh-key.key_name
}


//Hosts IP file
locals {
  workers_hosts_spec = join("\n", [for s in module.ec2.worker_public_ips : <<EOF
  Host worker${index(module.ec2.worker_public_ips, s)}
     Hostname ${tostring(s)}
     User ec2-user
     port 22
     IdentityFile ./${module.ssh-key.key_name}.pem
     StrictHostKeyChecking no
  EOF
  ])
}


resource "local_file" "vpc_hosts" {
  filename = "vpc_hosts"
  file_permission = "0666"
  content  = <<EOF
Host coordinator
     Hostname ${module.ec2.coordinator_public_ip}
     User ec2-user
     port 22
     IdentityFile ./${module.ssh-key.key_name}.pem
     StrictHostKeyChecking no

${local.workers_hosts_spec}

EOF
}

