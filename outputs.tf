# =========================
# VPC OUTPUT
# =========================

output "vpc_id" {

  description = "VPC ID"

  value = aws_vpc.main.id
}

# =========================
# PUBLIC SUBNET IDS
# =========================

output "public_subnet_ids" {

  description = "Public subnet IDs"

  value = [
    aws_subnet.subnets["public-web-1"].id,
    aws_subnet.subnets["public-web-2"].id
  ]
}

# =========================
# PRIVATE WEB SUBNET IDS
# =========================

output "private_web_subnet_ids" {

  description = "Private web subnet IDs"

  value = [
    aws_subnet.subnets["private-web-1"].id,
    aws_subnet.subnets["private-web-2"].id
  ]
}

# =========================
# PRIVATE APP SUBNET IDS
# =========================

output "private_app_subnet_ids" {

  description = "Private app subnet IDs"

  value = [
    aws_subnet.subnets["private-app-1"].id,
    aws_subnet.subnets["private-app-2"].id
  ]
}

# =========================
# PRIVATE DB SUBNET IDS
# =========================

output "private_db_subnet_ids" {

  description = "Private DB subnet IDs"

  value = [
    aws_subnet.subnets["private-db-1"].id,
    aws_subnet.subnets["private-db-2"].id
  ]
}

# =========================
# BASTION PUBLIC IP
# =========================

output "bastion_public_ip" {

  description = "Public IP of bastion host"

  value = aws_instance.bastion.public_ip
}

# =========================
# NAT GATEWAY IDS
# =========================

output "nat_gateway_ids" {

  description = "NAT Gateway IDs"

  value = {
    nat-1 = aws_nat_gateway.nat["nat-1"].id
    nat-2 = aws_nat_gateway.nat["nat-2"].id
  }
}