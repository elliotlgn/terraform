# AMI Amazon Linux 2023 (HVM, EBS) - on évite de figer un ID par région
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "instance_a" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_a.id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = var.instance_a_name
    AZ   = local.az_a
  })
}

resource "aws_instance" "instance_b" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_b.id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = var.instance_b_name
    AZ   = local.az_b
  })
}

# ---- 2 disques EBS de 8Go par instance (4 volumes, pas de boucle) ----

resource "aws_ebs_volume" "a_data_1" {
  availability_zone = local.az_a
  size              = var.ebs_volume_size_gb
  type              = var.ebs_volume_type

  tags = merge(local.common_tags, {
    Name     = "${var.instance_a_name}-data-1"
    Instance = var.instance_a_name
  })
}

resource "aws_ebs_volume" "a_data_2" {
  availability_zone = local.az_a
  size              = var.ebs_volume_size_gb
  type              = var.ebs_volume_type

  tags = merge(local.common_tags, {
    Name     = "${var.instance_a_name}-data-2"
    Instance = var.instance_a_name
  })
}

resource "aws_ebs_volume" "b_data_1" {
  availability_zone = local.az_b
  size              = var.ebs_volume_size_gb
  type              = var.ebs_volume_type

  tags = merge(local.common_tags, {
    Name     = "${var.instance_b_name}-data-1"
    Instance = var.instance_b_name
  })
}

resource "aws_ebs_volume" "b_data_2" {
  availability_zone = local.az_b
  size              = var.ebs_volume_size_gb
  type              = var.ebs_volume_type

  tags = merge(local.common_tags, {
    Name     = "${var.instance_b_name}-data-2"
    Instance = var.instance_b_name
  })
}

resource "aws_volume_attachment" "a_attach_1" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.a_data_1.id
  instance_id = aws_instance.instance_a.id
}

resource "aws_volume_attachment" "a_attach_2" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.a_data_2.id
  instance_id = aws_instance.instance_a.id
}

resource "aws_volume_attachment" "b_attach_1" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.b_data_1.id
  instance_id = aws_instance.instance_b.id
}

resource "aws_volume_attachment" "b_attach_2" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.b_data_2.id
  instance_id = aws_instance.instance_b.id
}
