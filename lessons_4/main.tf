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
    
    ingress {
        from_port = 80
        to_port = 80
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
  root_block_device {
  delete_on_termination = true
  }
  

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      user        = "centos"
      type        = "ssh"
      private_key = file("~/.ssh/terraform_key")
      agent       = true
    }
    inline = [
      "sudo setenforce 0",
      "sudo echo '${file("~/.terraform.d/nginx.repo")}' > ~/nginx.repo",
      "sudo cp ~/nginx.repo /etc/yum.repos.d/",
      "sudo yum -y install nginx",
      "sudo echo '${file("~/.terraform.d/jenkins.conf")}' > ~/jenkins.conf",
      "sudo cp ~/jenkins.conf /etc/nginx/conf.d/",
      "sudo yum install wget -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import http://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum -y install jenkins java-1.8.0-openjdk",
      "sudo systemctl start nginx",
      "sudo systemctl start jenkins"
      
    ]
  }
  tags = {
    Name = "HelloWorld"
  }
}
