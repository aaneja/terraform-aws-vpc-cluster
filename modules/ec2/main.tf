
variable "base_install" {
  type     = string
  nullable = false
  default  = <<EOF
cd /tmp

sudo apt-get -y update
sudo yum -y install git htop

echo "Installing Azul JDK"
wget -q https://cdn.azul.com/zulu/bin/zulu17.36.13-ca-jdk17.0.4-linux.x86_64.rpm
sudo yum install -y zulu17.36.13-ca-jdk17.0.4-linux.x86_64.rpm
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


// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "r5.4xlarge"
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
    "Name"     = "COORDINATOR",
    "trino-id" = "COORDINATOR"
  }

}

// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "r5.2xlarge"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  iam_instance_profile        = aws_iam_instance_profile.dev-resources-iam-profile.name
  user_data                   = <<EOF
#!/bin/bash

echo "Adding Coordinator IP to hosts"
echo "${aws_instance.ec2_public.private_ip} coordinator" >> /etc/hosts

${var.base_install}
EOF

  count = 4

  tags = {
    "Name"     = "WORKER",
    "trino-id" = "WORKER"
  }

}
