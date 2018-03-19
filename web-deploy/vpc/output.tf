output "public_subnet_id_1b" {
value = "${aws_subnet.us-east-1b-public.id}"
}
output "vpc_id" {
value = "${aws_vpc.default.id}"
}
output "cidr" {
value = "${aws_vpc.default.cidr_block}"
}
output "availability_zone-1b" {
value = "${aws_subnet.us-east-1b-public.availability_zone}"
}
output "availability_zone-1d" {
value = "${aws_subnet.us-east-1d-public.availability_zone}"
}
output "public_subnet_id_1d" {
value = "${aws_subnet.us-east-1d-public.id}"
}
