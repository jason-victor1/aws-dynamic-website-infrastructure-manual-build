# Security Group Design

## Purpose

This document explains the security group model used in the AWS dynamic three-tier web application lab.

The goal of the design is to enforce tiered traffic flow:

```text
Internet
  → Application Load Balancer
  → Private EC2 Web Servers
  → Private Amazon RDS MySQL Database
```

Administrative access is separated from application traffic and routed through EC2 Instance Connect Endpoint instead of exposing SSH directly to the internet.

---

## Security Group Summary

| Security Group | Attached To | Inbound Rules | Source |
|---|---|---|---|
| ALB Security Group | Application Load Balancer | HTTP 80, HTTPS 443 | Internet |
| Web Server Security Group | EC2 web servers | HTTP 80, HTTPS 443 | ALB Security Group |
| Web Server Security Group | EC2 web servers | SSH 22 | EC2 Instance Connect Endpoint SG |
| EC2 Instance Connect Endpoint SG | EC2 Instance Connect Endpoint | No inbound rule required | N/A |
| Database Migration Server SG | Temporary EC2 migration server | SSH 22 | EC2 Instance Connect Endpoint SG |
| RDS Database SG | Amazon RDS MySQL | MySQL/Aurora 3306 | Web Server SG |
| RDS Database SG | Amazon RDS MySQL | MySQL/Aurora 3306 | Database Migration Server SG |

---

## Component-Level Design

### 1. Application Load Balancer Security Group

**Purpose:** Public application entry point.

Allowed inbound traffic:

| Type | Port | Source |
|---|---:|---|
| HTTP | 80 | 0.0.0.0/0 |
| HTTPS | 443 | 0.0.0.0/0 |

Security rationale:

- The ALB is the only internet-facing application component.
- Public HTTP/HTTPS access terminates at the ALB, not directly at the EC2 web servers.
- This keeps the application servers private.

---

### 2. Web Server Security Group

**Purpose:** Protect EC2 instances running the LAMP application stack.

Allowed inbound traffic:

| Type | Port | Source |
|---|---:|---|
| HTTP | 80 | ALB Security Group |
| HTTPS | 443 | ALB Security Group |
| SSH | 22 | EC2 Instance Connect Endpoint SG |

Security rationale:

- Web servers do not accept HTTP/HTTPS directly from the internet.
- Web traffic must come through the ALB.
- SSH is not open to the internet.
- Administrative access is only allowed from EC2 Instance Connect Endpoint.

---

### 3. EC2 Instance Connect Endpoint Security Group

**Purpose:** Provide private administrative access to EC2 instances.

Inbound:

| Type | Port | Source |
|---|---:|---|
| None required | N/A | N/A |

Outbound:

| Type | Port | Destination |
|---|---:|---|
| SSH | 22 | VPC CIDR or approved private subnet CIDR |

Security rationale:

- The endpoint does not require an inbound rule for this lab workflow.
- The endpoint provides a controlled path for connecting to private EC2 instances.
- This avoids exposing SSH directly to the public internet.

---

### 4. Database Migration Server Security Group

**Purpose:** Temporarily allow access to an EC2 instance used to migrate SQL data into RDS.

Allowed inbound traffic:

| Type | Port | Source |
|---|---:|---|
| SSH | 22 | EC2 Instance Connect Endpoint SG |

Security rationale:

- The migration server only needs administrative access long enough to perform database migration.
- It does not need public SSH.
- It should be removed after migration is complete.

---

### 5. RDS Database Security Group

**Purpose:** Restrict database access to only approved application and migration components.

Allowed inbound traffic:

| Type | Port | Source |
|---|---:|---|
| MySQL/Aurora | 3306 | Web Server SG |
| MySQL/Aurora | 3306 | Database Migration Server SG |

Security rationale:

- The database is not public.
- Only the application tier can connect to the database during normal operation.
- The temporary migration server can connect only for the migration workflow.
- No direct database access is allowed from the internet.

---

## Traffic Boundary Model

```text
Public Zone
  Internet
    ↓
  ALB Security Group
    ↓ HTTP/HTTPS only

Private Application Zone
  Web Server Security Group
    ↓ MySQL only

Private Data Zone
  RDS Security Group
```

Administrative path:

```text
Operator
  ↓
EC2 Instance Connect Endpoint
  ↓ SSH
Private EC2 instances
```

---

## Evidence to Capture

Recommended screenshots:

- Full security group list filtered by project VPC
- ALB security group inbound rules
- Web server security group inbound rules
- EC2 Instance Connect Endpoint security group outbound rule
- Database migration server security group inbound rule
- RDS database security group inbound rules
- EC2 instance details showing private subnet placement
- RDS details showing private subnet group and public access disabled

Before publishing screenshots, redact:

- AWS account ID
- Resource IDs if desired
- RDS endpoint
- Public IPs
- Real domain names
- Any credential material
