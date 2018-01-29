provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "admin" {
  key_name = "admin"
  public_key = "${file("../../.keys/id_rsa_admin.pub")}"
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_incoming_ssh"
  description = "Allow ssh connections on port 22"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
  name = "allow_incoming_http"
  description = "Allow http connections on port 80"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_https" {
  name = "allow_incoming_https"
  description = "Allow https connections on port 443"

  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-41e0b93b"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.admin.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.allow_http.id}",
    "${aws_security_group.allow_https.id}",
    "${aws_security_group.allow_ssh.id}"
  ]

  provisioner "file" {
    source      = "../../.keys/id_rsa_deploy"
    destination = "/home/ubuntu/.ssh/id_rsa_deploy"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("../../.keys/id_rsa_admin")}"
    }
  }

  provisioner "chef" {
    environment     = "_default"
    run_list        = ["backend_app::default"]
    node_name       = "backend-app"
    server_url      = "https://api.chef.io/organizations/fedekau"
    recreate_client = true
    user_name       = "fedekau"
    user_key        = "${file("../chef/.chef/fedekau.pem")}"
    version         = "13.6.4"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("../../.keys/id_rsa_admin")}"
    }
  }

  provisioner "local-exec" {
    command = "cd ../chef && knife node run_list set backend-app 'role[backend-app]'"
  }

  provisioner "local-exec" {
    command = "echo 'REACT_APP_API_HOST_NAME=${aws_instance.backend.public_dns}' > ../../frontend-app/.env.production"
  }

  provisioner "local-exec" {
    command = "echo 'REACT_APP_API_PORT=${lookup(aws_security_group.allow_http.ingress[0], "to_port")}' >> ../../frontend-app/.env.production"
  }
}
