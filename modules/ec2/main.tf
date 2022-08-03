
// Install some basic software on the box
variable "base_install" {
  type     = string
  nullable = false
  default  = <<EOF
sudo apt-get -y update
sudo yum -y install git htop
EOF
}


// Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.dev-resources-iam-role.name
}
resource "aws_iam_role" "dev-resources-iam-role" {
  name               = "dev-ssm-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    stack = "test"
  }
}
resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.dev-resources-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


// Coordinator
resource "aws_instance" "coordinator" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = var.coordinator_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  iam_instance_profile        = aws_iam_instance_profile.dev-resources-iam-profile.name

  user_data = <<EOF
#!/bin/bash
echo "127.0.0.1 coordinator" >> /etc/hosts
touch /home/ec2-user/isCoordinator

${var.base_install}

EOF

  tags = {
    "Name"     = "COORDINATOR"
  }

}

// Workers
resource "aws_instance" "worker" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = var.worker_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  iam_instance_profile        = aws_iam_instance_profile.dev-resources-iam-profile.name
  user_data                   = <<EOF
#!/bin/bash

echo "Adding Coordinator IP to hosts"
echo "${aws_instance.coordinator.private_ip} coordinator" >> /etc/hosts

${var.base_install}
EOF

  count = var.worker_count

  tags = {
    "Name"     = "WORKER"
  }

}
