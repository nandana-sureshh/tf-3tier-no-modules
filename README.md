# Terraform 3-Tier AWS Infrastructure

## Project Overview

This project provisions a production-style, EKS-ready AWS infrastructure using Terraform without modules.

The infrastructure follows a highly available 3-tier architecture design with:

* Public Subnets
* Private Application Subnets
* Private Database Subnets
* NAT Gateways in each Availability Zone
* Isolated Database Layer
* Bastion Host Access
* Security Group Segmentation
* Terraform Best Practices

---

# Architecture Design

```text
                    INTERNET
                        |
                Internet Gateway
                        |
        ---------------------------------
        |                               |
   Public Subnet 1                 Public Subnet 2
    (AZ-1a)                          (AZ-1b)
        |                               |
     NAT-1                           NAT-2
        |                               |
-------------------------------------------------------
|                     |                               |
|                     |                               |
Private Web/App   Private Web/App              Private DB
Subnet AZ-1a      Subnet AZ-1b                 Subnets
        |               |                      (Isolated)
        |               |
      Future EKS Worker Nodes
```

---

# Technologies Used

* Terraform
* AWS VPC
* AWS EC2
* AWS NAT Gateway
* AWS Security Groups
* AWS Route Tables
* AWS Internet Gateway

---

# Terraform Concepts Implemented

## Variables

Used to avoid hardcoding values.

Examples:

* AWS Region
* VPC CIDR
* AMI IDs
* Key Pair
* Subnet Configurations

---

## Locals

Used for reusable common tags.

Example:

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

---

## Outputs

Used for:

* VPC ID
* Subnet IDs
* Bastion Public IP
* NAT Gateway IDs

---

## Meta Arguments

### for_each

Used for:

* Subnets
* NAT Gateways
* Route Tables
* Route Table Associations

---

## depends_on

Used to explicitly control dependencies.

Example:

* NAT Gateway depends on Internet Gateway

---

# Folder Structure

```text
terraform-3tier/
│
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── locals.tf
├── vpc.tf
├── subnets.tf
├── igw.tf
├── nat.tf
├── route_tables.tf
├── security_groups.tf
├── bastion.tf
├── outputs.tf
```

---

# Infrastructure Components

# 1. VPC

## Configuration

| Property      | Value       |
| ------------- | ----------- |
| CIDR          | 10.1.0.0/16 |
| DNS Support   | Enabled     |
| DNS Hostnames | Enabled     |

---

# 2. Subnets

A total of 8 subnets were created across 2 Availability Zones.

---

## Public Subnets

| Subnet       | CIDR        | AZ         |
| ------------ | ----------- | ---------- |
| public-web-1 | 10.1.1.0/24 | us-east-1a |
| public-web-2 | 10.1.2.0/24 | us-east-1b |

### Purpose

* Bastion Host
* NAT Gateways
* Public-facing resources

---

## Private Web Subnets

| Subnet        | CIDR         | AZ         |
| ------------- | ------------ | ---------- |
| private-web-1 | 10.1.11.0/24 | us-east-1a |
| private-web-2 | 10.1.12.0/24 | us-east-1b |

### Purpose

* Future EKS Worker Nodes
* Frontend Pods

---

## Private App Subnets

| Subnet        | CIDR         | AZ         |
| ------------- | ------------ | ---------- |
| private-app-1 | 10.1.21.0/24 | us-east-1a |
| private-app-2 | 10.1.22.0/24 | us-east-1b |

### Purpose

* Backend Services
* NodeJS APIs
* Internal Applications

---

## Private DB Subnets

| Subnet       | CIDR         | AZ         |
| ------------ | ------------ | ---------- |
| private-db-1 | 10.1.31.0/24 | us-east-1a |
| private-db-2 | 10.1.32.0/24 | us-east-1b |

### Purpose

* Database Layer
* Isolated Storage Tier

---

# 3. Internet Gateway

Used to provide internet access to:

* Public Subnets
* Bastion Host
* NAT Gateways

---

# 4. NAT Gateways

Two NAT Gateways were created for High Availability.

| NAT Gateway | AZ         |
| ----------- | ---------- |
| nat-1       | us-east-1a |
| nat-2       | us-east-1b |

---

# NAT Gateway Purpose

Allows private subnets to:

* Download packages
* Pull container images
* Access internet securely

Without exposing private resources publicly.

---

# 5. Route Tables

A total of 5 Route Tables were implemented.

---

## Public Route Table

### Routes

| Destination | Target           |
| ----------- | ---------------- |
| 0.0.0.0/0   | Internet Gateway |

### Associated Subnets

* public-web-1
* public-web-2

---

## Private App/Web Route Tables

### AZ-1a Route Table

| Destination | Target |
| ----------- | ------ |
| 0.0.0.0/0   | nat-1  |

Associated with:

* private-web-1
* private-app-1

---

### AZ-1b Route Table

| Destination | Target |
| ----------- | ------ |
| 0.0.0.0/0   | nat-2  |

Associated with:

* private-web-2
* private-app-2

---

## Private DB Route Tables

### Important Security Design

Database Route Tables DO NOT contain internet routes.

This ensures:

* Database isolation
* Reduced attack surface
* Improved security posture

---

# 6. Security Groups

---

## Bastion Security Group

### Inbound Rules

| Port | Protocol | Source    |
| ---- | -------- | --------- |
| 22   | TCP      | 0.0.0.0/0 |

### Purpose

SSH access to Bastion Host.

---

## Web Security Group

### Inbound Rules

| Port | Protocol | Source     |
| ---- | -------- | ---------- |
| 80   | TCP      | VPC CIDR   |
| 22   | TCP      | Bastion SG |

### Purpose

Frontend/Web Layer communication.

---

## App Security Group

### Inbound Rules

| Port | Protocol | Source     |
| ---- | -------- | ---------- |
| 4000 | TCP      | Web SG     |
| 22   | TCP      | Bastion SG |

### Purpose

Backend application communication.

---

## DB Security Group

### Inbound Rules

| Port | Protocol | Source     |
| ---- | -------- | ---------- |
| 3306 | TCP      | App SG     |
| 22   | TCP      | Bastion SG |

### Purpose

Database access control.

---

# Security Design Highlights

* SG-to-SG communication
* No public DB exposure
* Layered network segmentation
* Principle of least privilege

---

# 7. Bastion Host

## Configuration

| Property  | Value         |
| --------- | ------------- |
| Type      | t2.micro      |
| Placement | Public Subnet |
| Public IP | Enabled       |

---

## Purpose

Used for:

* SSH Access
* Administrative Access
* Jump Server Functionality

---

# High Availability Design

The infrastructure is highly available because:

* Resources distributed across 2 AZs
* NAT Gateway in each AZ
* Multi-AZ subnet architecture
* Separate route tables per AZ

---

# Database Isolation Strategy

Database subnets:

* Do NOT have internet routes
* Are accessible only from App Security Group
* Are fully private

This mimics production-grade security design.

---

# Future EKS Integration

This infrastructure is designed to support future EKS deployment.

Planned future additions:

* EKS Cluster
* Worker Nodes
* Kubernetes Deployments
* Helm Charts
* Ingress Controllers
* HPA
* CI/CD Pipelines

---

# Planned Kubernetes Design

| Layer    | Kubernetes Component |
| -------- | -------------------- |
| Frontend | Deployment           |
| Backend  | Deployment           |
| Database | External MongoDB     |

---

# MongoDB Architecture Decision

MongoDB will NOT run inside Kubernetes.

Reason:

* Databases are stateful
* Kubernetes is optimized for stateless workloads
* Easier backup and management externally

Planned Architecture:

```text
EKS Pods
    ↓
External MongoDB
```

Possible external DB options:

* MongoDB Atlas
* AWS DocumentDB
* Self-managed MongoDB EC2

---

# Terraform Commands Used

## Initialize Terraform

```bash
terraform init
```

---

## Format Terraform Code

```bash
terraform fmt
```

---

## Validate Configuration

```bash
terraform validate
```

---

## Preview Infrastructure Changes

```bash
terraform plan
```

---

## Deploy Infrastructure

```bash
terraform apply
```

---

## Destroy Infrastructure

```bash
terraform destroy
```

---

# Key Learnings

* Terraform Resource Dependencies
* for_each Meta Argument
* Route Table Design
* NAT High Availability
* Security Group Chaining
* Infrastructure as Code Best Practices
* Multi-AZ Networking
* Database Isolation
* EKS-Ready Infrastructure Design

---

# Final Outcome

Successfully implemented a production-style, optimized, highly available, EKS-ready AWS infrastructure using Terraform without modules.
