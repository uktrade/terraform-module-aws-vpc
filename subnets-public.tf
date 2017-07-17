resource "aws_subnet" "public" {
  count = "${length(data.aws_availability_zones.vpc_az.names)}"
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${cidrsubnet(var.aws_conf["cidr_block"], 4, count.index + 1)}"
  availability_zone = "${element(data.aws_availability_zones.vpc_az.names, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.aws_conf["project"]} Public Subnet ${element(data.aws_availability_zones.vpc_az.names, count.index)}"
    Stack = "${var.aws_conf["project"]}"
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
    cidr_block = "${var.aws_conf["peering.cidr_block"]}"
    vpc_peering_connection_id = "${data.aws_vpc_peering_connection.peer.id}"
  }

  tags {
    Name = "${var.aws_conf["project"]} Public Routing Table ${join("/", data.aws_availability_zones.vpc_az.names)}"
    Stack = "${var.aws_conf["project"]}"
  }
  depends_on = ["aws_subnet.public"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_vpc_endpoint_route_table_association" "public_vpc_endpoint" {
  vpc_endpoint_id = "${aws_vpc_endpoint.vpc_endpoint.id}"
  route_table_id  =  "${aws_route_table.public.id}"
  depends_on = ["aws_route_table.public"]
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
