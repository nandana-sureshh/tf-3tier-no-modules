resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id #creates implicit dependency--VPC must exist BEFORE IGW
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}