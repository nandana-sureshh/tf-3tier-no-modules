resource "aws_security_group" "bastion_sg" {

  name        = "bastion-sg"
  description = "Security group for bastion host"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH access"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [var.my_ip]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "bastion-sg"
    }
  )
}

resource "aws_security_group" "web_sg" {

  name        = "web-sg"
  description = "Security group for web tier"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP access"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "SSH from bastion"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      aws_security_group.bastion_sg.id
    ]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "web-sg"
    }
  )
}

resource "aws_security_group" "app_sg" {

  name        = "app-sg"
  description = "Security group for app tier"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "App access from web tier"

    from_port = 4000
    to_port   = 4000
    protocol  = "tcp"

    security_groups = [
      aws_security_group.web_sg.id
    ]
  }

  ingress {
    description = "SSH from bastion"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      aws_security_group.bastion_sg.id
    ]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "app-sg"
    }
  )
}

resource "aws_security_group" "db_sg" {

  name        = "db-sg"
  description = "Security group for db tier"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "Mongodb from app tier"

    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"

    security_groups = [
      aws_security_group.app_sg.id
    ]
  }

  ingress {
    description = "SSH from bastion"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      aws_security_group.bastion_sg.id
    ]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "db-sg"
    }
  )
}