# Cleanup and Cost Controls

## Purpose

This document lists cleanup steps for the AWS dynamic three-tier web application lab.

Cloud cleanup is part of the project because several resources can create ongoing charges if left running.

---

## High-Cost / Ongoing-Cost Resources to Watch

Resources to pay special attention to:

- NAT Gateway
- Elastic IP if unattached or associated with chargeable resources
- EC2 instances
- Application Load Balancer
- RDS database
- EBS volumes
- AMIs and snapshots
- Route 53 hosted zones and registered domains
- CloudWatch logs/metrics depending on retention and usage

---

## Recommended Cleanup Order

Use this order to avoid dependency errors:

1. Delete Auto Scaling Group.
2. Delete Launch Template.
3. Delete Application Load Balancer.
4. Delete Target Group.
5. Delete temporary EC2 instances.
6. Delete RDS database if no longer needed.
7. Delete NAT Gateway.
8. Release Elastic IP.
9. Delete unused AMIs if no longer needed.
10. Delete associated snapshots if no longer needed.
11. Delete temporary security groups after dependent resources are removed.
12. Remove temporary S3 artifacts if no longer needed.
13. Review CloudWatch logs and retention settings.
14. Confirm billing/cost dashboard after cleanup.

---

## NAT Gateway Cleanup

NAT Gateway is commonly one of the first resources to remove when stepping away from the lab.

Checklist:

- Delete NAT Gateway.
- Wait until deletion completes.
- Release associated Elastic IP if no longer needed.
- Update or note that private route table default route may show as unavailable/blackhole after NAT deletion.

When resuming the lab:

- Recreate NAT Gateway.
- Allocate/associate Elastic IP.
- Update private route table to use the new NAT Gateway.

---

## RDS Cleanup

Before deleting RDS, decide whether to keep a final snapshot.

For labs:

- A final snapshot may not be necessary if the database can be recreated.
- If keeping a final snapshot, document why.
- Delete snapshots later if they are no longer needed.

Never publish screenshots containing:

- RDS endpoint if considered sensitive
- Database username
- Secret values
- Account ID

---

## AMI and Snapshot Cleanup

Creating an AMI can also create backing snapshots.

If the AMI is no longer needed:

1. Deregister the AMI.
2. Delete associated EBS snapshots.

This prevents forgotten storage costs.

---

## S3 Cleanup

S3 may contain:

- Application code package
- SQL migration files
- Supporting PHP/config files
- Logs or artifacts

Before publishing to GitHub, do not include course-owned application code unless you have permission.

For cleanup:

- Delete unnecessary lab artifacts.
- Keep only sanitized documentation artifacts.
- Confirm no secrets were uploaded.

---

## Final Verification

After cleanup, validate:

- No running EC2 instances remain unless intentionally retained.
- No active NAT Gateway remains unless intentionally retained.
- No active ALB remains unless intentionally retained.
- No RDS instance remains unless intentionally retained.
- Elastic IPs are released if unused.
- AMIs/snapshots are reviewed.
- Billing dashboard reflects expected resource state.

---

## Portfolio Note

Include cleanup evidence in the repository because it demonstrates operational maturity.

Suggested evidence:

- NAT Gateway deleted screenshot
- Elastic IP released screenshot
- ASG deleted screenshot
- RDS deleted or retained-with-purpose note
- Final cost dashboard screenshot with sensitive details redacted
