# Troubleshooting Notes

## Issue: Application `.env` File Did Not Update the Database Password Correctly

### Context

During the application server configuration phase, the deployment commands updated most values in the application `.env` file. However, the database password value did not update correctly.

The application required the RDS database endpoint, database name, username, and password in the environment configuration file. The database credentials were stored in AWS Secrets Manager.

---

## Symptoms

Observed behavior:

- The application configuration file updated most expected values.
- The database endpoint appeared correctly.
- The application name/domain values appeared correctly.
- The database password placeholder remained incorrect or did not update as expected.
- The application could not fully connect to the database until the password value was corrected.

---

## Likely Cause

The likely cause was special characters in the AWS Secrets Manager-generated RDS password interfering with the shell command used to update the `.env` file.

This is a common deployment issue: generated secrets may contain characters that are meaningful to shell commands, `sed` expressions, quotes, or environment-variable expansion.

---

## Resolution Used in the Lab

The manual workaround was:

1. Connect to the private EC2 application server.
2. Navigate to the application directory.
3. Open the `.env` file using `vi`.
4. Enter insert mode.
5. Replace the placeholder database password with the value retrieved from AWS Secrets Manager.
6. Save and exit the file.
7. Use `cat` or another verification method to confirm the expected values were present.
8. Restart or validate the application service as needed.

Example command pattern:

```bash
sudo vi .env
```

Inside `vi`:

```text
i                # enter insert mode
<edit value>
Esc              # leave insert mode
:wq!             # write and quit
```

---

## Security Note

Do not commit the `.env` file to GitHub.

The `.env` file may contain:

- Database usernames
- Database passwords
- Application keys
- Internal endpoints
- Secret values

Add `.env` to `.gitignore`:

```gitignore
.env
*.env
.env.*
```

Use a sanitized example only:

```env
APP_NAME=example-app
APP_ENV=lab
APP_URL=https://example.com

DB_CONNECTION=mysql
DB_HOST=<rds-endpoint-placeholder>
DB_PORT=3306
DB_DATABASE=<database-name-placeholder>
DB_USERNAME=<username-placeholder>
DB_PASSWORD=<password-managed-in-secrets-manager>
```

---

## Better Production Fixes

The manual `vi` fix is acceptable for a lab troubleshooting note, but it is not ideal for production.

Better approaches:

### 1. Use safer secret injection

Avoid fragile shell substitution for secret values that may contain special characters.

### 2. Use parameterized templates

Generate the application environment file from a controlled template instead of editing values in-place with brittle commands.

### 3. Use AWS SDK or application-native secret retrieval

Where appropriate, allow the application to retrieve secrets directly from AWS Secrets Manager using an IAM role.

### 4. Scope IAM permissions tightly

For production, avoid wildcard access to all S3 buckets or all secrets. Scope permissions to the specific S3 bucket and Secrets Manager secret ARNs required by the application.

### 5. Add validation checks

After deployment, automatically verify:

- `.env` contains no placeholder values.
- Required environment variables exist.
- The application can connect to the database.
- Apache or the application service is running.
- ALB target health is passing.

---

## Lesson Learned

Secrets automation must account for special characters and shell interpretation issues. A deployment can appear mostly successful while still failing because one sensitive value was not written correctly.

For portfolio documentation, this is worth including because it shows:

- Real troubleshooting
- Understanding of secret-handling risk
- Awareness of automation fragility
- Ability to convert a lab failure into a production improvement backlog
