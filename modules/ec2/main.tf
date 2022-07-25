
variable "base_install" {
  type     = string
  nullable = false
  default = <<EOF
cd /home/ec2-user

echo "Installing JDK"
sudo apt-get -y update
wget https://cdn.azul.com/zulu/bin/zulu17.36.13-ca-jdk17.0.4-linux.x86_64.rpm
sudo yum install -y zulu17.36.13-ca-jdk17.0.4-linux.x86_64.rpm

echo "Installing Trino"
wget https://repo1.maven.org/maven2/io/trino/trino-server/391/trino-server-391.tar.gz
tar xzf trino-server-391.tar.gz
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

// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  
  user_data = <<EOF
#!/bin/bash
cd /home/ec2-user
touch is_coordinator

${var.base_install}

EOF

  tags = {
    "Name" = "COORDINATOR",
    "trino-id" = "COORDINATOR"
  }

}

// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]

  user_data = <<EOF
#!/bin/bash

echo "Adding IP to hosts"
echo "${aws_instance.ec2_public.private_ip} coordinator" > /etc/hosts


EOF

  count                       = 2

  tags = {
    "Name" = "WORKER",
    "trino-id" = "WORKER"
  }

}