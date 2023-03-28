terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Terraform   = "true"
    Environment = "production"
    Config      = "opencat_team"
  }
}

resource "aws_instance" "ubuntu_instance" {
  ami           = var.ec2_ami # Ubuntu 22.04 LTS (Arm64) image ID
  instance_type = "t4g.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id]
  key_name      = var.key_name # Replace with your own key pair name

  tags = merge(local.common_tags, {
    Name = "opencat-team-instance"
  })
}

resource "aws_eip" "ubuntu_instance_ip" {
  instance = aws_instance.ubuntu_instance.id
  vpc      = true

  tags = merge(local.common_tags, {
    Name = "opencat-team-instance-eip"
  })
}

resource "aws_security_group" "allow_http_https_ssh" {
  name        = "allow_http_https_ssh"
  description = "Allow inbound traffic on ports 22, 80 and 443"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "allow_http_https_ssh"
  })
}

resource "null_resource" "run_docker_container" {
  depends_on = [aws_instance.ubuntu_instance]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_eip.ubuntu_instance_ip.public_ip
  }

  provisioner "remote-exec" {
    inline = [
        "sudo apt-get update",
        "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
        "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
        "echo \"deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
        "sudo apt-get update",
        "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
        "sudo systemctl start docker",
        "sudo systemctl enable docker",
        "sudo docker run -d --name opencatd -e TLS_DOMAIN=${var.sub_domain_name}.${var.domain_name} -p 80:80 -p 443:443 -p 6255:443 -v /srv/data:/opt/db -v /srv/certs:/opt/certs bayedev/opencatd",
    ]
    }
}

resource "aws_route53_zone" "zone" {
  name = var.domain_name

  tags = merge(local.common_tags, {
    Name = "${var.domain_name}-zone"
  })
}

resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "${var.sub_domain_name}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.ubuntu_instance_ip.public_ip]
}
