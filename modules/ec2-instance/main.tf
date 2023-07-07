provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region =  "${var.region}"
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# upload private key for ssh
resource "aws_key_pair" "generated_key" {
  key_name   =  "${var.instance_name}"
  public_key = tls_private_key.pk.public_key_openssh
    provisioner "local-exec" { # Create a "pem" to your computer
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./${var.instance_name}.pem"
  }
  tags = {
    Name = "${var.instance_name}"
  }
}

# get current stable ubuntu ami for provided version=
data "aws_ssm_parameter" "latest_ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/${var.ubuntu_version}/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_vpc" "new-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_subnet" "new_subnet" {
  cidr_block = "${cidrsubnet(aws_vpc.new-vpc.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.new-vpc.id}"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_security_group" "ingress-all-ssh" {
name = "allow-all-sg"
vpc_id = "${aws_vpc.new-vpc.id}"
// Allow SSH
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 8000
    to_port = 8000
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_instance" "ec2_instance" {
    ami = data.aws_ssm_parameter.latest_ubuntu_ami.value
    count = "1"
    subnet_id = "${aws_subnet.new_subnet.id}"
    instance_type = "${var.instance_type}"
    key_name = aws_key_pair.generated_key.key_name
    security_groups = ["${aws_security_group.ingress-all-ssh.id}"]
    # Allow internet access so we can ssh to our instance
    associate_public_ip_address = true

    tags = {
      Name = "${var.instance_name}"
    }
}

// Allow access from internet via internet gateway
resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.new-vpc.id}"
  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_route_table" "route-table-gw" {
  vpc_id = "${aws_vpc.new-vpc.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }
  tags = {
    Name = "${var.instance_name}"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.new_subnet.id}"
  route_table_id = "${aws_route_table.route-table-gw.id}"
}