data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_efs_file_system" "fs" {
  creation_token = "my-product"
  encrypted = false
}

resource "aws_security_group" "efs_sg" {
  name        = "allow_efs"
  description = "Allow EFS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "EFS from VPC"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

data "aws_subnet" "us_east_1a" {
  availability_zone = "us-east-1a"
  default_for_az = true
}

resource "aws_efs_mount_target" "mount_us_east_1a" {
  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = data.aws_subnet.us_east_1a.id
  security_groups = [aws_security_group.efs_sg.id]
}

data "aws_subnet" "us_east_1b" {
  availability_zone = "us-east-1b"
  default_for_az = true
}

resource "aws_efs_mount_target" "mount_us_east_1b" {
  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = data.aws_subnet.us_east_1b.id
  security_groups = [aws_security_group.efs_sg.id]
}

data "aws_subnet" "us_east_1c" {
  availability_zone = "us-east-1c"
  default_for_az = true
}

resource "aws_efs_mount_target" "mount_us_east_1c" {
  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = data.aws_subnet.us_east_1c.id
  security_groups = [aws_security_group.efs_sg.id]
}

data "aws_subnet" "us_east_1d" {
  availability_zone = "us-east-1d"
  default_for_az = true
}

resource "aws_efs_mount_target" "mount_us_east_1d" {
  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = data.aws_subnet.us_east_1d.id
  security_groups = [aws_security_group.efs_sg.id]
}

data "aws_subnet" "us_east_1e" {
  availability_zone = "us-east-1e"
  default_for_az = true
}

resource "aws_efs_mount_target" "mount_us_east_1e" {
  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = data.aws_subnet.us_east_1e.id
  security_groups = [aws_security_group.efs_sg.id]
}

data "aws_subnet" "us_east_1f" {
  availability_zone = "us-east-1f"
  default_for_az = true
}

resource "aws_efs_mount_target" "mount_us_east_1f" {
  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = data.aws_subnet.us_east_1f.id
  security_groups = [aws_security_group.efs_sg.id]
}
