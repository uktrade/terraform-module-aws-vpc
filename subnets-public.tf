resource "aws_subnet" "public" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${cidrsubnet(var.aws_conf["cidr_block"], 4, count.index + 1)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.default.ipv6_cidr_block, 8, count.index + 1)}"
  availability_zone = "${element(data.aws_availability_zones.vpc_az.names, count.index)}"
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true

  tags {
    Name = "${var.aws_conf["domain"]} Public Subnet ${element(data.aws_availability_zones.vpc_az.names, count.index)}"
    Stack = "${var.aws_conf["domain"]}"
    AvailabilityZone = "${element(data.aws_availability_zones.vpc_az.names, count.index)}"
    Type = "public"
  }
  depends_on = ["aws_vpc.default"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.ipv6-gw.id}"
  }

  tags {
    Name = "${var.aws_conf["domain"]} Public Routing Table ${join("/", data.aws_availability_zones.vpc_az.names)}"
    Stack = "${var.aws_conf["domain"]}"
  }
  depends_on = ["aws_subnet.public"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_vpc_endpoint_route_table_association" "public_vpc_endpoint_s3" {
  vpc_endpoint_id = "${aws_vpc_endpoint.vpc_endpoint_s3.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_vpc_endpoint_route_table_association" "public_vpc_endpoint_dynamodb" {
  vpc_endpoint_id = "${aws_vpc_endpoint.vpc_endpoint_dynamodb.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"

  depends_on = ["aws_route_table.public"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}
