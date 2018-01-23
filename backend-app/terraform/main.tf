provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "admin" {
  key_name = "admin"
  public_key = "${file("../../.keys/id_rsa_admin.pub")}"
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow ssh connections on port 22"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
  name = "allow_http"
  description = "Allow http connections on port 80"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-41e0b93b"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.admin.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_http.id}", "${aws_security_group.allow_ssh.id}"]
}

output "public_dns" {
  value = "${aws_instance.backend.public_dns}"
}
