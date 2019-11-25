resource "aws_key_pair" "terraform_key" {
  key_name = "terraform_key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGbAeaFQOBKzB+2wga+BQayKgbO4FFSvjfrEVLcA6IMIf1j8N/3xujEDD/qHLbui0s9+5t3DVUbGVhD3qxWUylaHDNOMfi8EbUFHyItDaqifV5kglXYQ893Y2/97UHioAxgu1NhDi2YdP3/Y7y94JStvE5aSNzGwWltpefZAAwV1ELNfIRCZLepsS2+f2QWUxWeh+G18g6CXEQlhQuQBp7MoKo6a/VaFLVqjcyc0zgP30i2hVo1i4UMCIKdCDhSXDJRrze8gWNFafRYZPkHxVUx519wFBfNnrEdM2uolyv3F/mpapB2H7OIcPDCUqaFAzpGba+bEg0e7DbOYIkH4l0qqiv2jRfdILi75HWVRNKegpT1C6G2BtYlfBBDJokpHyAs/KYcwNzwfv69UrqzFW77/VId4AyrLvsrJPVWn86Se/car/z8uVqJJP6r20TgMEZKwkLmT00FuRwrRTSQ2wR3im+qKQytYCFhmoeFlxVO0//i7UryebHHi73wESITa8= anmax@localhost.localdomain"
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
  tags = {
    Name = "HelloWorld"
  }
}
