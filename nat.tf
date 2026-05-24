resource "aws_eip" "nat_eip" {

  for_each = {
    nat-1 = "public-web-1"
    nat-2 = "public-web-2"
  }

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )
}

resource "aws_nat_gateway" "nat" {

  for_each = {
    nat-1 = "public-web-1"
    nat-2 = "public-web-2"
  }

  allocation_id = aws_eip.nat_eip[each.key].id

  subnet_id = aws_subnet.subnets[each.value].id

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )
}