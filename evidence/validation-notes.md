# Validation Notes

## Purpose

This file tracks the evidence collected during the AWS dynamic three-tier web application deployment.

Use this as a checklist before publishing the repository.

---

## Evidence Checklist

| Evidence | File | Status | Notes |
|---|---|---:|---|
| VPC and subnet layout | sanitized-screenshots/vpc-subnets.png | Sanitized | Replaced with uploaded screenshot |
| Security groups | sanitized-screenshots/security-groups.png | Sanitized | Replaced with uploaded screenshot |
| EC2 Instance Connect Endpoint | sanitized-screenshots/ec2-instance-connect-endpoint.png | Sanitized | Replaced with uploaded screenshot |
| RDS private subnet/database config | sanitized-screenshots/rds-private-subnet.png | Sanitized | Replaced with uploaded screenshot |
| Secrets Manager metadata/redacted value | Not captured | Not included | Screenshot was not available for this commit |
| ALB target health | sanitized-screenshots/alb-target-health.png | Sanitized | Replaced with uploaded screenshot |
| Route 53 record | Not captured | Not included | Screenshot was not available for this commit |
| Auto Scaling replacement test | sanitized-screenshots/autoscaling-replacement-test.png | Sanitized | Corrected: visible EC2 instance IDs redacted in table |

---

## Validation Tests

### Network

- [ ] VPC exists.
- [ ] Public subnets exist.
- [ ] Private application subnets exist.
- [ ] Private database subnets exist.
- [ ] Private route table routes outbound traffic through NAT Gateway when lab is active.

### Security Groups

- [ ] ALB accepts HTTP/HTTPS from internet.
- [ ] Web servers accept HTTP/HTTPS only from ALB SG.
- [ ] Web servers accept SSH only from EC2 Instance Connect Endpoint SG.
- [ ] RDS accepts MySQL only from web server SG and migration server SG.
- [ ] No direct public SSH is open to EC2 web servers.

### RDS and Secrets

- [ ] RDS public access is disabled.
- [ ] RDS is deployed into private database subnets.
- [ ] Database credentials are stored in Secrets Manager.
- [ ] Secret values are not visible in public screenshots.

### Application

- [ ] Web server runs Apache.
- [ ] Application files are present in the web directory.
- [ ] Environment file is configured.
- [ ] Application can connect to RDS.
- [ ] ALB target health is passing.

### Load Balancing and DNS

- [ ] ALB exists in public subnets.
- [ ] Target group includes healthy instances.
- [ ] HTTPS listener uses ACM certificate.
- [ ] Route 53 points domain/subdomain to ALB.

### Auto Scaling

- [ ] AMI created from configured web server.
- [ ] Launch Template uses custom AMI.
- [ ] ASG launches instances in private application subnets.
- [ ] ASG registers instances with target group.
- [ ] Terminated instance is replaced by ASG.

---

## Redaction Checklist

Before publishing screenshots, confirm removal of:

- [ ] AWS account ID
- [ ] Database password
- [ ] Secret values
- [ ] IAM access keys
- [ ] Sensitive public IPs
- [ ] RDS endpoint if not intended for public display
- [ ] Personal email/domain details if not intended for public display
- [ ] Any course-owned proprietary application code

## Redaction Notes

See [`redaction-notes.md`](redaction-notes.md) for screenshot sanitization details.


## Missing Evidence

The following screenshots were not captured for this commit:

- Secrets Manager redacted screenshot
- Route 53 record redacted screenshot

These can be added later if needed. The current repo still documents the Secrets Manager and Route 53 design decisions in the README and supporting documentation.
