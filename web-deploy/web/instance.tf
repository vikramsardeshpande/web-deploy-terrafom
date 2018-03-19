provider "aws" {
  #region = "${var.region}"
  region = "us-east-1"
}


data "terraform_remote_state" "vpc" {
  backend = "local"
  config {
    path = "/home/vikram-demo/web-deploy-project/vpc/terraform.tfstate"
  }
}
#resource "aws_instance" "bastion-1b" {
#	ami = "ami-1853ac65"
#	availability_zone = "${data.terraform_remote_state.vpc.availability_zone-1b}"
#	instance_type = "t2.micro"
#	subnet_id = "${data.terraform_remote_state.vpc.public_subnet_id_1b}"
#	security_groups = ["${aws_security_group.web.id}"]
#        key_name = "mykey"
#}
resource "aws_instance" "bastion-1d" {
	ami = "ami-1853ac65"
	availability_zone = "${data.terraform_remote_state.vpc.availability_zone-1d}"
	instance_type = "t2.micro"
	subnet_id = "${data.terraform_remote_state.vpc.public_subnet_id_1d}"
        security_groups = ["${aws_security_group.web.id}"]
        key_name = "mykey"
        associate_public_ip_address = true
}

# security group for web 
resource "aws_security_group" "web" {
  name = "web-project-example"
  description = "Security group for web that allows web traffic from internet"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   # self        = true
}

  tags {
    Name = "web-project-example"
  }
}
