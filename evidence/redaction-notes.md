# Screenshot Redaction Notes

## Corrected Redactions

- `autoscaling-replacement-test.png`
  - Corrected the redaction placement.
  - Redacted the two visible EC2 instance IDs in the Instance ID column.

## Re-saved Clean Copies

The following screenshots were re-saved from pixel data and written as new PNG files:

- `vpc-subnets.png`
- `security-groups.png`
- `ec2-instance-connect-endpoint.png`
- `rds-private-subnet.png`
- `alb-target-health.png`

## Visible Items Reviewed

The uploaded screenshots did not visibly show:

- AWS account ID
- IAM access keys
- Secret values
- Database password
- RDS endpoint
- Public IPv4 DNS value
- Public IPv4 address

## Not Captured

The following screenshots were not available for this commit:

- Secrets Manager redacted screenshot
- Route 53 record redacted screenshot

The repository should not include placeholder screenshots for evidence that was not captured.

## Auto Scaling Screenshot Fix

- `autoscaling-replacement-test.png`
  - Removed misplaced redaction boxes from the lower blank area.
  - Redacted the two visible EC2 instance IDs in the actual Instance ID column.
