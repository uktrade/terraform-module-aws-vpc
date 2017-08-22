resource "aws_subnet" "private" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${cidrsubnet(var.aws_conf["cidr_block"], 4, length(data.aws_availability_zones.vpc_az.names) + count.index + 1)}"
  availability_zone = "${element(data.aws_availability_zones.vpc_az.names, count.index)}"
  map_public_ip_on_launch = false
  assign_ipv6_address_on_creation = false

  tags {
    Name = "${var.aws_conf["domain"]} Private Subnet ${element(data.aws_availability_zones.vpc_az.names, count.index)}"
    Stack = "${var.aws_conf["domain"]}"
    AvailabilityZone = "${element(data.aws_availability_zones.vpc_az.names, count.index)}"
    Type = "private"
  }
  depends_on = ["aws_vpc.default"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_eip" "nat" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  vpc = true

  depends_on = ["aws_vpc.default"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_nat_gateway" "nat-gw" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  depends_on = ["aws_internet_gateway.default"]
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"

  depends_on = ["aws_eip.nat"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_route_table" "private" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat-gw.*.id, count.index)}"
  }

  route {
    ipv6_cidr_block = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.ipv6-gw.id}"
  }

  tags {
    Name = "${var.aws_conf["domain"]} Private Routing Table ${element(data.aws_availability_zones.vpc_az.names, count.index)}"
    Stack = "${var.aws_conf["domain"]}"
  }
  depends_on = ["aws_nat_gateway.nat-gw"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_vpc_endpoint_s3" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  vpc_endpoint_id = "${aws_vpc_endpoint.vpc_endpoint_s3.id}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "private_vpc_endpoint_dynamodb" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  vpc_endpoint_id = "${aws_vpc_endpoint.vpc_endpoint_dynamodb.id}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  depends_on = ["aws_route_table.private"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}
