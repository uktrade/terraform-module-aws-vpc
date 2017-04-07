data "null_data_source" "vpc_conf" {
  inputs = {
    region = "${data.aws_region.region.name}"
    availability_zones = "${data.aws_availability_zones.availability_zones.names}"
    id = "${aws_vpc.default.id}"
    subnets_public = "${join(",", aws_subnet.public.*.id)}"
    subnets_private = "${join(",", aws_subnet.private.*.id)}"
    availability_zones = "${join(",", data.aws_availability_zones.vpc_az.names)}"
    security_group = "${aws_security_group.base-sg.id}"
    profile = "${aws_iam_instance_profile.default.id}"
    role = "${aws_iam_role.default.id}"
    role_arn = "${aws_iam_role.default.arn}"
    zone_id = "${aws_route53_zone.root_zone.zone_id}"
    kms = "${aws_kms_key.kms_key.arn}"
    nat_public = "${join(",", aws_nat_gateway.nat-gw.*.public_ip)}"
    nat_private = "${join(",", aws_nat_gateway.nat-gw.*.private_ip)}"
    ami = "${data.aws_ami.ami.image_id}"
    s3_endpoint = "${join(",", aws_vpc_endpoint.vpc_endpoint.cidr_blocks)}"
  }
}

output "vpc_conf" {
  value = "${map(
              "region", "${data.aws_region.region.name}",
              "id", "${aws_vpc.default.id}",
              "subnets_public", "${join(",", aws_subnet.public.*.id)}",
              "subnets_private", "${join(",", aws_subnet.private.*.id)}",
              "availability_zones", "${join(",", data.aws_availability_zones.vpc_az.names)}",
              "security_group", "${aws_security_group.base-sg.id}",
              "profile", "${aws_iam_instance_profile.default.id}",
              "role", "${aws_iam_role.default.id}",
              "role_arn", "${aws_iam_role.default.arn}",
              "zone_id", "${aws_route53_zone.root_zone.zone_id}",
              "kms", "${aws_kms_key.kms_key.arn}",
              "nat_public", "${join(",", aws_nat_gateway.nat-gw.*.public_ip)}",
              "nat_private", "${join(",", aws_nat_gateway.nat-gw.*.private_ip)}",
              "ami", "${data.aws_ami.ami.image_id}",
              "s3_endpoint", "${join(",", aws_vpc_endpoint.vpc_endpoint.cidr_blocks)}"
            )}"
}
