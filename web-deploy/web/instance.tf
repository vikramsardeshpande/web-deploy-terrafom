provider "aws" {
  #region = "${var.region}"
  region = "us-east-1"
}


data "terraform_remote_state" "vpc" {
  backend = "local"
  config {
    path = "../vpc/terraform.tfstate"
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
     #   user_data= "#!/bin/bash\n yum update -y \n yum install httpd -y \n service httpd restart"
	provisioner "file" {
    	source = "index.html"
       	destination = "/tmp/index.html"
         }
	provisioner "remote-exec" {
  	  inline = [
          "sudo yum update -y",
          "sudo yum install httpd -y",
          "sudo service httpd restart", 
    	  "sudo chmod +x /tmp/index.html",
	  "sudo chmod 777 /var/www/html",
       	  "/usr/bin/sudo /bin/cp /tmp/index.html /var/www/html/index.html"
  	  ]
 	 }
    	connection { 
	user = "${var.INSTANCE_USERNAME}"
        private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
        }
	tags {
             Name = "demo v1"
            }
 
	
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
# Our elb security group to access 
# the ELB over HTTP 
 resource "aws_security_group" "elb" { 
   name        = "elb_sg" 
   description = "Used in the terraform" 
 
 
   vpc_id = "${data.terraform_remote_state.vpc.vpc_id}" 
 
 
   # HTTP access from anywhere 
   ingress { 
     from_port   = 80 
     to_port     = 80 
     protocol    = "tcp" 
     cidr_blocks = ["0.0.0.0/0"] 
   } 
 
 
   # outbound internet access 
  egress { 
     from_port   = 0 
     to_port     = 0 
     protocol    = "-1" 
     cidr_blocks = ["0.0.0.0/0"] 
   } 
 
 
 # ensure the VPC has an Internet gateway or this step will fail 
#   depends_on = ["aws_internet_gateway.gw"] 
 } 
resource "aws_elb" "web" { 
   name = "example-elb" 
 
 
   # The same availability zone as our instance 
  subnets = ["${data.terraform_remote_state.vpc.public_subnet_id_1d}"] 
  # subnet_id = "${data.terraform_remote_state.vpc.public_subnet_id_1d}" 
 
   security_groups = ["${aws_security_group.elb.id}"] 
 
 
   listener { 
     instance_port     = 80 
     instance_protocol = "http" 
     lb_port           = 80 
     lb_protocol       = "http" 
   } 
 
 
   health_check { 
     healthy_threshold   = 2 
     unhealthy_threshold = 2 
     timeout             = 3 
     target              = "HTTP:80/" 
     interval            = 30 
   } 
  # The instance is registered automatically 
 
 
   instances                   = ["${aws_instance.bastion-1d.id}"] 
   cross_zone_load_balancing   = true 
   idle_timeout                = 400 
   connection_draining         = true 
   connection_draining_timeout = 400 
 } 
 
 
 resource "aws_lb_cookie_stickiness_policy" "default" { 
   name                     = "lbpolicy" 
   load_balancer            = "${aws_elb.web.id}" 
   lb_port                  = 80 
   cookie_expiration_period = 600 
 } 
