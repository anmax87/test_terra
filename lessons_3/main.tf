resource "aws_key_pair" "terraform_key" {
  key_name = "terraform_key"
    public_key = file("~/.ssh/terraform_key.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  
  ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["679593333241"]
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"
  key_name = "terraform_key"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      user        = "centos"
      type        = "ssh"
      private_key = file("~/.ssh/terraform_key")
      agent       = true
    }
    inline = [
      "sudo yum update -y"
      ]
  }
  tags = {
    Name = "HelloWorld"
  }
}
