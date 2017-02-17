data "aws_ami" "ami" {
  most_recent = true
  name_regex = "${var.aws_conf["ami_name"]}"
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}
