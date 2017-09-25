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

resource "aws_ami_copy" "ami_encrypt" {
  name = "${data.aws_ami.ami.name}"
  description = "${data.aws_ami.ami.description}"
  source_ami_id = "${data.aws_ami.ami.image_id}"
  source_ami_region = "${data.aws_region.region.name}"
  encrypted = true
  tags = "${data.aws_ami.ami.tags}"
}
