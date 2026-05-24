# =========================
# PUBLIC ROUTE TABLE
# =========================

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "public-rt"
    }
  )
}

# =========================
# PRIVATE APP + WEB RTs
# =========================

resource "aws_route_table" "private_app_web_rt" {

  for_each = {
    private-app-web-rt-1a = "nat-1"
    private-app-web-rt-1b = "nat-2"
  }

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.nat[each.value].id
  }

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )
}

# =========================
# PRIVATE DB RTs
# =========================

resource "aws_route_table" "private_db_rt" {

  for_each = {
    private-db-rt-1a = "db-1a"
    private-db-rt-1b = "db-1b"
  }

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )
}

# =========================
# PUBLIC ROUTE ASSOCIATIONS
# =========================

resource "aws_route_table_association" "public_assoc" {

  for_each = {
    public-web-1 = "public-web-1"
    public-web-2 = "public-web-2"
  }

  subnet_id = aws_subnet.subnets[each.key].id

  route_table_id = aws_route_table.public_rt.id
}

# =========================
# PRIVATE APP + WEB ASSOCIATIONS
# =========================

resource "aws_route_table_association" "private_app_web_assoc" {

  for_each = {
    private-web-1 = "private-app-web-rt-1a"
    private-app-1 = "private-app-web-rt-1a"

    private-web-2 = "private-app-web-rt-1b"
    private-app-2 = "private-app-web-rt-1b"
  }

  subnet_id = aws_subnet.subnets[each.key].id

  route_table_id = aws_route_table.private_app_web_rt[each.value].id
}

# =========================
# PRIVATE DB ASSOCIATIONS
# =========================

resource "aws_route_table_association" "private_db_assoc" {

  for_each = {
    private-db-1 = "private-db-rt-1a"
    private-db-2 = "private-db-rt-1b"
  }

  subnet_id = aws_subnet.subnets[each.key].id

  route_table_id = aws_route_table.private_db_rt[each.value].id
}