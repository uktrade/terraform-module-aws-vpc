resource "aws_kms_key" "kms_key" {
  description = "KMS key for ${var.aws_conf["domain"]}"
}

resource "aws_iam_role" "default" {
  name = "${var.aws_conf["domain"]}-role"
  assume_role_policy = "${file("${path.module}/policies/default-role.json")}"
}

resource "aws_iam_role_policy" "default" {
  name = "${var.aws_conf["domain"]}-role-policy"
  policy = "${file("${path.module}/policies/default-policy.json")}"
  role = "${aws_iam_role.default.id}"
}

resource "aws_iam_instance_profile" "default" {
  name = "${var.aws_conf["domain"]}-profile"
  path = "/"
  roles = ["${aws_iam_role.default.name}"]

  lifecycle {
    create_before_destroy = true
  }
}
