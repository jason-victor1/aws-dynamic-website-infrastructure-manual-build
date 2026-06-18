# IAM and Secrets Manager

## Purpose

This document explains the IAM and secrets-management pattern used in the AWS dynamic web application deployment.

The goal is to avoid hardcoded AWS credentials and avoid storing database credentials directly in scripts or GitHub.

---

## IAM Role Pattern

The EC2 instances use an IAM role attached through an instance profile.

This role allows EC2 to:

- Read application artifacts from S3.
- Retrieve database credentials from AWS Secrets Manager.

This is better than placing IAM access keys on the instance.

---

## Example IAM Permission Scope

The lab policy used permissions similar to:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ReadAccess",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SecretsManagerReadAccess",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    }
  ]
}
```

## Production Improvement

For production, avoid wildcard resources.

A stronger production pattern would scope access to:

- The specific S3 bucket ARN.
- The specific S3 object prefix.
- The specific Secrets Manager secret ARN.

Example production-style direction:

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject"
  ],
  "Resource": "arn:aws:s3:::example-app-artifacts/*"
}
```

```json
{
  "Effect": "Allow",
  "Action": [
    "secretsmanager:GetSecretValue",
    "secretsmanager:DescribeSecret"
  ],
  "Resource": "arn:aws:secretsmanager:REGION:ACCOUNT_ID:secret:example-secret"
}
```

Replace placeholders before use.

---

## Secrets Manager Pattern

AWS Secrets Manager stores the RDS database username and password.

The application or deployment script retrieves the secret value instead of hardcoding the password.

Benefits:

- Reduces secret exposure in scripts.
- Keeps credentials out of GitHub.
- Allows future support for rotation.
- Allows IAM-based access control to the secret.

---

## Secret Handling Rules

Do not commit:

- `.env`
- Database passwords
- Secret JSON values
- Access keys
- Screenshots showing secret values
- RDS credential pages without redaction

Use placeholders in documentation:

```env
DB_HOST=<rds-endpoint-placeholder>
DB_DATABASE=<database-name-placeholder>
DB_USERNAME=<username-placeholder>
DB_PASSWORD=<stored-in-secrets-manager>
```

---

## Evidence to Capture

Recommended sanitized screenshots:

- IAM role attached to EC2 instance
- IAM policy permissions summary
- Secrets Manager secret metadata page
- Secret value page only if the value is fully redacted
- EC2 instance profile details

---

## Lessons Learned

- IAM roles are safer than static credentials on EC2.
- Secrets Manager helps keep database credentials out of source control.
- Wildcard IAM permissions may be acceptable for a beginner lab but should be tightened for production.
- Screenshots can accidentally leak sensitive data and must be sanitized before publishing.
