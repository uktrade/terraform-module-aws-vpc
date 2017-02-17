resource "aws_route53_zone" "root_zone" {
  name = "${var.aws_conf["domain"]}."
  tags {
    Name = "${var.aws_conf["domain"]}"
    Stack = "${var.aws_conf["domain"]}"
  }

  lifecycle {
    prevent_destroy = true
  }
}
