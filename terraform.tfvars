aws_region   = "us-east-1"
project_name = "3tier"
environment  = "dev"

vpc_cidr = "10.1.0.0/16"

key_name = "kubernetes-project"

subnets = {

  public-web-1 = {
    cidr = "10.1.1.0/24"
    az   = "us-east-1a"
    type = "public"
  }

  public-web-2 = {
    cidr = "10.1.2.0/24"
    az   = "us-east-1b"
    type = "public"
  }

  private-web-1 = {
    cidr = "10.1.11.0/24"
    az   = "us-east-1a"
    type = "private-web"
  }

  private-web-2 = {
    cidr = "10.1.12.0/24"
    az   = "us-east-1b"
    type = "private-web"
  }

  private-app-1 = {
    cidr = "10.1.21.0/24"
    az   = "us-east-1a"
    type = "private-app"
  }

  private-app-2 = {
    cidr = "10.1.22.0/24"
    az   = "us-east-1b"
    type = "private-app"
  }


  private-db-1 = {
    cidr = "10.1.31.0/24"
    az   = "us-east-1a"
    type = "private-db"
  }

  private-db-2 = {
    cidr = "10.1.32.0/24"
    az   = "us-east-1b"
    type = "private-db"
  }
}

my_ip = "0.0.0.0/0"

ami_id = "ami-091138d0f0d41ff90"