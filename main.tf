data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "kops_state" {
  bucket = "kops-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_versioning" "kops_state_versioning" {
  bucket = aws_s3_bucket.kops_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_key_pair" "controller-key" {
  key_name   = "controller-key"
  public_key = file("controller-key.pub")
}

resource "aws_instance" "kops" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.controller-key.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "kops"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install snapd -y",
      "curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '\"' -f 4)/kops-linux-amd64",
      "chmod +x kops",
      "sudo mv kops /usr/local/bin/kops",
      "sudo snap install aws-cli --classic",
      "sudo snap install kubectl --classic",
      "ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N '' -q",
      "mkdir -p /home/ubuntu/.aws",
      <<-EOF
cat <<CONFIG > /home/ubuntu/.aws/credentials
[default]
aws_access_key_id=${var.aws_access_key}
aws_secret_access_key=${var.aws_secret_key}
CONFIG
EOF
,
      "echo 'kops create cluster --name=<example.yourdomain.com> --state=s3://${aws_s3_bucket.kops_state.bucket} --zones=us-east-1a,us-east-1b --node-count=2 --node-size=t3.small --control-plane-size=t3.medium --dns-zone=<example.yourdomain.com> --node-volume-size=12 --control-plane-volume-size=12 --ssh-public-key=/home/ubuntu/.ssh/id_rsa.pub'",
      "echo 'kops update cluster --name=<example.yourdomain.com> --state=s3://${aws_s3_bucket.kops_state.bucket} --yes --admin'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("controller-key")
      host        = self.public_ip
      timeout     = "10m"
    }
  }

}
