provider "aws" {
  region = "${var.aws_conf["region"]}"
  alias = "aws.peer"
}

data "aws_vpc_peering_connection" "peer" {
  vpc_id = "${aws_vpc.default.id}"
  peer_vpc_id = "${var.aws_conf["peering.vpc_id"]}"
  peer_owner_id = "${var.aws_conf["peering.account_id"]}"
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider = "aws.peer"
  vpc_peering_connection_id = "${data.aws_vpc_peering_connection.peer.id}"
  auto_accept = true

  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }
}
