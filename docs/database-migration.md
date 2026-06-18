# Database Migration Workflow

## Purpose

This document explains how the SQL migration was handled for the dynamic AWS web application project.

The application requires a MySQL database with the expected schema and seed data. Because Amazon RDS starts as a managed database service without the application-specific schema, the SQL migration file must be loaded into RDS before the application can function correctly.

---

## Migration Architecture

```text
S3 SQL Migration File
  ↓
Temporary EC2 Migration Server
  ↓
Amazon RDS MySQL
```

The temporary EC2 migration server runs in a private subnet and connects to RDS over MySQL port 3306.

---

## Why Use a Temporary Migration Server?

The RDS database is private and not directly reachable from the public internet. The temporary migration server provides a controlled internal compute resource that can:

- Connect to RDS using the approved security group path.
- Retrieve migration files from S3.
- Retrieve database credentials from Secrets Manager.
- Run database migration commands.

After the migration is complete, the server should be stopped or deleted to reduce cost and attack surface.

---

## Required Access

The migration server needs:

### Network Access

- SSH from EC2 Instance Connect Endpoint security group.
- MySQL access to RDS security group on port 3306.
- Outbound access to retrieve packages or artifacts if needed.

### IAM Access

- Read access to S3 migration artifacts.
- Read access to Secrets Manager database credentials.

---

## Migration Process

High-level workflow:

1. Upload SQL migration file to S3.
2. Launch temporary EC2 migration server in a private subnet.
3. Attach the database migration security group.
4. Attach IAM role with S3 and Secrets Manager read access.
5. Connect through EC2 Instance Connect Endpoint.
6. Retrieve the SQL file from S3.
7. Retrieve RDS credentials from Secrets Manager.
8. Run the migration command.
9. Verify that the database schema/data exists.
10. Delete the temporary migration server.

---

## Example Placeholder Commands

> These are sanitized templates. Replace placeholders before use.

```bash
export AWS_REGION="<region>"
export S3_SQL_URI="s3://<bucket-name>/<migration-file>.sql"
export DB_HOST="<rds-endpoint>"
export DB_NAME="<database-name>"
export SECRET_ID="<secrets-manager-secret-id>"
```

Retrieve the SQL file:

```bash
aws s3 cp "$S3_SQL_URI" ./migration.sql
```

Retrieve secret value:

```bash
aws secretsmanager get-secret-value   --secret-id "$SECRET_ID"   --region "$AWS_REGION"
```

Example MySQL import pattern:

```bash
mysql   --host="$DB_HOST"   --user="<db-username>"   --password   "$DB_NAME" < migration.sql
```

---

## Flyway Note

The lab used a migration workflow with Flyway. In a production-style environment, Flyway or a similar migration tool can help track schema versions and apply database changes more consistently.

Recommended production practices:

- Store migrations in version control.
- Review migration scripts before execution.
- Test migrations in a lower environment first.
- Capture migration logs.
- Use rollback/restore planning.
- Back up the database before major schema changes.

---

## Evidence to Capture

Recommended sanitized evidence:

- S3 migration file object visible in artifact bucket
- Migration server EC2 instance in private subnet
- Migration server security group
- RDS security group allowing MySQL from migration server SG
- Successful migration command output with sensitive values redacted
- Application working after migration
- Migration server deleted after completion

---

## Lessons Learned

- Dynamic applications often require schema/data migration before the application works.
- Private RDS design improves security but requires a controlled internal migration path.
- Temporary migration servers should be removed after use.
- Migration commands must avoid leaking database passwords into terminal history, screenshots, or GitHub.
