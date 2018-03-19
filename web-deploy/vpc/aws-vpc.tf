provider "aws" {
#	access_key = "${var.aws_access_key}"
#	secret_key = "${var.aws_secret_key}"
	region = "us-east-1"
}
resource "aws_vpc" "default" {
	cidr_block = "10.0.0.0/16"
        enable_dns_hostnames = true
}
resource "aws_internet_gateway" "default" {
	vpc_id = "${aws_vpc.default.id}"
}
resource "aws_subnet" "us-east-1b-public" {
	vpc_id = "${aws_vpc.default.id}"

	cidr_block = "10.0.0.0/24"
	availability_zone = "us-east-1b"
}
resource "aws_subnet" "us-east-1d-public" {
	vpc_id = "${aws_vpc.default.id}"

	cidr_block = "10.0.2.0/24"
	availability_zone = "us-east-1d"
}

resource "aws_route_table" "us-east-1-public" {
	vpc_id = "${aws_vpc.default.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}
}
# Routing table for public subnets
resource "aws_route_table_association" "us-east-1b-public" {
	subnet_id = "${aws_subnet.us-east-1b-public.id}"
	route_table_id = "${aws_route_table.us-east-1-public.id}"
}

resource "aws_route_table_association" "us-east-1d-public" {
	subnet_id = "${aws_subnet.us-east-1d-public.id}"
	route_table_id = "${aws_route_table.us-east-1-public.id}"
}
