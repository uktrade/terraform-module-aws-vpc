variable "aws_conf" {
  type = "map"
  default = {}
}

data "aws_region" "region" {
  name = "${var.aws_conf["region"]}"
}

resource "aws_vpc" "default" {
  cidr_block = "${var.aws_conf["cidr_block"]}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.aws_conf["domain"]} VPC"
    Stack = "${var.aws_conf["domain"]}"
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

data "aws_availability_zones" "vpc_az" {
  state = "available"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.aws_conf["domain"]} VPC Gateway"
    Stack = "${var.aws_conf["domain"]}"
  }
  depends_on = ["aws_vpc.default"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_vpc_dhcp_options" "search" {
  domain_name = "${var.aws_conf["domain"]}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.aws_conf["domain"]} DHCP"
    Stack = "${var.aws_conf["domain"]}"
  }
  depends_on = ["aws_subnet.public", "aws_subnet.private"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_vpc_dhcp_options_association" "search" {
  vpc_id = "${aws_vpc.default.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.search.id}"

  depends_on = ["aws_subnet.public", "aws_subnet.private"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.${data.aws_region.region.name}.s3"
}

resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.aws_conf["domain"]} VPN Gateway"
    Stack = "${var.aws_conf["domain"]}"
  }
  depends_on = ["aws_vpc.default"]
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}

resource "aws_security_group" "base-sg" {
  name = "${var.aws_conf["domain"]}-base-sg"
  description = "Allow outgoing traffic"

  vpc_id = "${aws_vpc.default.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.aws_conf["cidr_block"]}"]
  }

  tags {
    Name = "${var.aws_conf["domain"]} default SG"
    Stack = "${var.aws_conf["domain"]}"
  }
  depends_on = ["aws_vpc.default"]
  lifecycle {
    create_before_destroy = true
  }
}
