# Deployment Guide

## Overview

This guide summarizes the deployment phases for the AWS dynamic three-tier web application project.

The deployment pattern is:

```text
Route 53
  → Application Load Balancer
  → Private EC2 web servers
  → Private Amazon RDS MySQL database
```

Supporting services include S3 for application artifacts, Secrets Manager for database credentials, EC2 Instance Connect Endpoint for private administrative access, AMI/Launch Template for repeatable server provisioning, and Auto Scaling Group for resiliency.

---

## Prerequisites

- AWS account
- Existing VPC with public and private subnets
- Basic understanding of VPC routing
- Basic Linux command-line knowledge
- Basic MySQL/database knowledge
- Domain name if testing Route 53 and ACM end-to-end
- Sanitization process for public portfolio screenshots

---

## Phase 1: Network Preparation

### Goal

Prepare the VPC for private application instances that need temporary outbound internet access.

### Actions

1. Reuse the existing VPC.
2. Confirm public and private subnets exist across at least two Availability Zones.
3. Recreate the NAT Gateway if it was previously deleted for cost control.
4. Allocate or associate an Elastic IP for the NAT Gateway.
5. Update the private route table to route outbound internet traffic through the NAT Gateway.

### Validation

- NAT Gateway state is available.
- Private route table has a default route to the NAT Gateway.
- Private EC2 instances can install packages or retrieve required dependencies.

---

## Phase 2: Security Group Design

### Goal

Create security groups before deploying dependent resources.

### Actions

Create dedicated security groups for:

- EC2 Instance Connect Endpoint
- Application Load Balancer
- EC2 web servers
- Temporary database migration server
- RDS MySQL database

### Validation

- Web servers only allow HTTP/HTTPS from the ALB security group.
- Web servers only allow SSH from the EC2 Instance Connect Endpoint security group.
- RDS only allows MySQL from the web server security group and migration server security group.
- No direct public SSH exists on private EC2 instances.

More detail: [Security Group Design](security-groups.md)

---

## Phase 3: EC2 Instance Connect Endpoint

### Goal

Enable private administrative access to EC2 instances without exposing SSH to the internet.

### Actions

1. Create an EC2 Instance Connect Endpoint in a private subnet.
2. Attach the EC2 Instance Connect Endpoint security group.
3. Use the endpoint when connecting to private EC2 instances.

### Validation

- Endpoint status is available.
- Private EC2 instances can be reached using EC2 Instance Connect.
- No public IP is required on the private instances.

---

## Phase 4: Application Artifact Storage

### Goal

Store deployment files in S3 so private EC2 instances can retrieve them through their IAM role.

### Actions

1. Upload the application package to S3.
2. Upload any required PHP support/configuration files.
3. Upload SQL migration files.

### Validation

- S3 bucket contains required deployment artifacts.
- EC2 IAM role has permission to list/read the required bucket objects.

---

## Phase 5: IAM Role and Secrets Manager

### Goal

Allow EC2 instances to retrieve application artifacts and database credentials without hardcoded AWS keys.

### Actions

1. Create a custom IAM policy for:
   - `s3:ListBucket`
   - `s3:GetObject`
   - `secretsmanager:DescribeSecret`
   - `secretsmanager:GetSecretValue`
2. Attach the policy to an IAM role.
3. Attach the IAM role to EC2 instances that need S3 and Secrets Manager access.
4. Configure RDS credentials to be managed by AWS Secrets Manager.

### Validation

- EC2 instance profile is attached.
- EC2 can retrieve S3 artifacts.
- EC2 can retrieve the database secret value.

More detail: [IAM and Secrets Manager](iam-and-secrets-manager.md)

---

## Phase 6: RDS MySQL Provisioning

### Goal

Deploy a private MySQL database for the dynamic application.

### Actions

1. Create an RDS subnet group using private database subnets.
2. Create an RDS MySQL database.
3. Disable public access.
4. Attach the RDS database security group.
5. Create the initial application database.
6. Store or manage the master credentials through AWS Secrets Manager.

### Validation

- RDS is available.
- Public access is disabled.
- RDS is associated with private database subnets.
- RDS security group only allows approved MySQL sources.

---

## Phase 7: Database Migration

### Goal

Load the SQL migration file into RDS.

### Actions

1. Launch a temporary EC2 database migration server in a private subnet.
2. Attach the database migration server security group.
3. Attach the IAM role for S3 and Secrets Manager access.
4. Connect through EC2 Instance Connect Endpoint.
5. Download the SQL migration file from S3.
6. Run the migration workflow.
7. Validate that database tables/data exist.
8. Remove the temporary migration server when complete.

More detail: [Database Migration](database-migration.md)

---

## Phase 8: Application Server Deployment

### Goal

Deploy and configure the LAMP-based web application.

### Actions

1. Launch an EC2 web server in a private application subnet.
2. Attach the web server security group.
3. Attach the IAM role for S3 and Secrets Manager access.
4. Install Apache, PHP, MySQL client tools, and required dependencies.
5. Download application artifacts from S3.
6. Extract/copy application files into the web directory.
7. Configure environment variables or `.env` values for RDS connectivity.
8. Start and enable Apache.

### Validation

- Apache is running.
- Application files are in the expected web directory.
- `.env` values are populated correctly.
- Web server can connect to RDS.
- ALB health checks pass after load balancer setup.

---

## Phase 9: Load Balancer, DNS, and TLS

### Goal

Expose the private application tier through a public HTTPS entry point.

### Actions

1. Create a target group for the EC2 web server.
2. Configure target group health checks.
3. Create an internet-facing Application Load Balancer in public subnets.
4. Attach the ALB security group.
5. Configure HTTP and HTTPS listeners.
6. Use ACM certificate for HTTPS.
7. Create Route 53 DNS records pointing the custom domain to the ALB.

### Validation

- Target health is healthy.
- HTTPS listener is active.
- Domain resolves to the ALB.
- Application loads from the custom domain.

---

## Phase 10: AMI, Launch Template, and Auto Scaling

### Goal

Convert the configured application server into a reusable scaling pattern.

### Actions

1. Create an AMI from the configured EC2 web server.
2. Create a Launch Template using the AMI.
3. Configure instance type, IAM role, networking, and security group settings.
4. Create an Auto Scaling Group across private application subnets.
5. Attach the ASG to the ALB target group.
6. Validate desired capacity.
7. Test replacement behavior by terminating an instance.

### Validation

- ASG launches instances from the custom AMI.
- Instances register with the target group.
- Health checks pass.
- ASG replaces a terminated instance.

---

## Phase 11: Cleanup

Follow the cleanup guide to avoid unnecessary charges.

See: [Cleanup and Cost Controls](cleanup.md)
