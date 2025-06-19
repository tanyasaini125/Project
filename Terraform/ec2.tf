## This is ec2 instance
resource "aws_instance" "web" {
  ami                         = data.aws_ami.rhel10.id
  instance_type               = "t3.micro"
  availability_zone           = "ap-south-1a"
  key_name                    = "dishu-key"
  subnet_id                   = aws_subnet.public-subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.Firewall.id]
  iam_instance_profile        = aws_iam_instance_profile.s3_profile.name

  user_data = <<-EOF
  #!/bin/bash
  yum install  httpd awscli -y
  systemctl start httpd
  systemctl enable httpd
  aws s3 sync s3://tanya-connected-bucket /var/www/html
EOF

  tags = {
    Name = "ec2"
  }
}

## This is public key
resource "aws_key_pair" "dishu" {
  key_name   = "dishu-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxjNPxPzSKkpYxrXc6nYGbyQFi6vFjYdMTGQHW+FpMj root@Terraform"
}

## This is ami genrate
data "aws_ami" "rhel10" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
