# Pre-GitHub Checklist

Use this checklist before committing, pushing, opening a PR, or making the repository public.

This checklist is designed for the AOS cloud project series and covers repository hygiene, secret scanning, evidence review, documentation, cost controls, security controls, and portfolio readiness.

---

## 1. Repository Hygiene

Run:

    git status --short
    find . -name ".DS_Store" -print
    git ls-files | grep -i '\.DS_Store' || echo "No .DS_Store files tracked"
    git diff --check

Checklist:

- [ ] Working tree reviewed.
- [ ] No accidental `.DS_Store` files are tracked.
- [ ] No local cache, temp, log, or generated clutter is staged.
- [ ] `.gitignore` covers OS files, environment files, Terraform state, logs, and local build artifacts.
- [ ] `git diff --check` returns no whitespace errors.
- [ ] Branch name matches the work being committed.
- [ ] Commit message clearly describes the project milestone.

---

## 2. Secret and Credential Safety

Run:

    grep -RniE 'AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|aws_secret_access_key|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|password|secret|token|api[_-]?key' . \
      --exclude-dir=.git \
      --exclude-dir=node_modules \
      --exclude-dir=.terraform || true

Run Gitleaks:

    gitleaks git .

Run TruffleHog:

    trufflehog filesystem . --no-update --results=verified,unknown

If the repo already has commit history:

    trufflehog git file://. --no-update --results=verified,unknown

Checklist:

- [ ] No AWS access keys.
- [ ] No private keys.
- [ ] No passwords.
- [ ] No real database passwords or connection strings.
- [ ] No real API tokens.
- [ ] No secrets in shell snippets.
- [ ] No secrets in screenshots.
- [ ] No secrets in documentation.
- [ ] Gitleaks returns no leaks.
- [ ] TruffleHog returns no verified or unknown secrets requiring review.

---

## 3. Evidence Sanitization

Run:

    find evidence -type f | sort 2>/dev/null || echo "No evidence directory found"

Checklist:

- [ ] Screenshots are sanitized.
- [ ] AWS account IDs are redacted where appropriate.
- [ ] Public IP addresses are redacted where appropriate.
- [ ] ARNs are redacted or partially masked if sensitive.
- [ ] Email addresses are redacted.
- [ ] Hosted zone IDs, database endpoints, and DNS values are reviewed.
- [ ] No raw sensitive screenshots are committed.
- [ ] Evidence files have clear names.
- [ ] `evidence/redaction-notes.md` exists if screenshots or CLI outputs are included.

Suggested structure:

    evidence/
      README.md
      redaction-notes.md
      sanitized-screenshots/
      validation-notes.md

---

## 4. Documentation Completeness

Checklist:

- [ ] `README.md` explains the business problem.
- [ ] `README.md` explains the architecture.
- [ ] `README.md` lists the AWS services used.
- [ ] `README.md` explains deployment at a high level.
- [ ] `README.md` explains validation/testing.
- [ ] `README.md` explains cleanup.
- [ ] `README.md` explains cost controls.
- [ ] `README.md` explains security controls.
- [ ] `README.md` includes portfolio-ready language.
- [ ] README claims are supported by evidence.
- [ ] README does not overclaim production readiness.
- [ ] Placeholders and sample values are clearly labeled.

Minimum recommended README sections:

    # Project Title
    
    ## Business Problem
    
    ## Architecture
    
    ## Services Used
    
    ## Security Controls
    
    ## Cost Controls
    
    ## Deployment Summary
    
    ## Validation Evidence
    
    ## Cleanup
    
    ## Lessons Learned
    
    ## Portfolio Relevance

---

## 5. Architecture and Diagram Review

Checklist:

- [ ] Architecture diagram exists if the project uses multiple AWS services.
- [ ] Diagram matches the actual deployed architecture.
- [ ] Diagram does not expose sensitive identifiers.
- [ ] README references the diagram.
- [ ] Public and private boundaries are labeled.
- [ ] Security groups, routing, compute, database, load balancer, DNS, and container services are shown where relevant.

Suggested path:

    diagrams/architecture.png

---

## 6. Script Safety and Validation

Run shell syntax checks:

    find scripts -name "*.sh" -print -exec bash -n {} \; 2>/dev/null || echo "No shell scripts found"

If Python exists:

    find . -name "*.py" -print -exec python3 -m py_compile {} \;

Checklist:

- [ ] Bash scripts use `set -Eeuo pipefail`.
- [ ] Scripts validate required commands before making changes.
- [ ] Scripts validate required environment variables.
- [ ] Scripts fail early before AWS-side effects if required config is missing.
- [ ] Scripts avoid hardcoded secrets.
- [ ] Scripts use placeholders or `.env.example`.
- [ ] Risky operations are commented.
- [ ] Cleanup/destructive commands are clearly marked.
- [ ] Syntax checks pass.

---

## 7. AWS Cost and Runaway Usage Controls

Checklist:

- [ ] README mentions cost exposure.
- [ ] Cleanup steps are documented.
- [ ] Persistent resources are identified.
- [ ] Expensive services are reviewed before final push.
- [ ] ALB, NAT Gateway, EKS, ECS, RDS, ECR, CloudWatch Logs, Route 53, and Elastic IP costs are reviewed where applicable.
- [ ] Budget alarm or AWS Budget guardrail strategy is referenced where relevant.
- [ ] No expensive resources are left running unintentionally.
- [ ] Project includes teardown commands or a cleanup guide.

---

## 8. Cloud Security Controls

Checklist:

- [ ] IAM permissions are least-privilege where practical.
- [ ] No root-user usage is implied.
- [ ] Security groups are documented.
- [ ] No broad inbound access unless justified.
- [ ] Databases are private where applicable.
- [ ] Secrets are handled through placeholders, environment variables, or AWS Secrets Manager.
- [ ] Logging and monitoring are mentioned where relevant.
- [ ] Public exposure is intentional and documented.
- [ ] Cleanup avoids leaving public endpoints active.
- [ ] Misconfiguration risks are explicitly discussed.

Misconfiguration Defense Layer review:

- [ ] Preventive controls documented.
- [ ] Detective controls documented.
- [ ] Cleanup or containment controls documented.
- [ ] Ownership/tagging controls documented where applicable.
- [ ] Evidence-producing validation documented.

---

## 9. Validation Evidence

Checklist:

- [ ] Application or workload was tested.
- [ ] Deployment path was validated.
- [ ] Screenshots prove key milestones.
- [ ] CLI outputs were reviewed and sanitized.
- [ ] Troubleshooting notes are included if meaningful.
- [ ] Known limitations are documented.
- [ ] README claims match actual evidence.

Suggested files:

    docs/deployment-guide.md
    docs/troubleshooting.md
    docs/cleanup.md
    evidence/validation-notes.md

---

## 10. GitHub Readiness

Run:

    git status --short
    git remote -v
    git log --oneline -5

Checklist:

- [ ] Remote repo is correct.
- [ ] Branch is correct.
- [ ] README renders properly on GitHub.
- [ ] Images render properly on GitHub.
- [ ] Internal notes are not accidentally public.
- [ ] Repo description is clear.
- [ ] Repo topics are relevant.
- [ ] Visibility is intentional.
- [ ] Final push goes to the correct GitHub repository.

---

## 11. Portfolio Positioning

Checklist:

- [ ] Project title is clear.
- [ ] Business problem is clear.
- [ ] Technical implementation is clear.
- [ ] Security value is clear.
- [ ] Cost-control value is clear.
- [ ] Automation or repeatability value is clear.
- [ ] Evidence is credible.
- [ ] The repo does not look like a tutorial copy-paste.
- [ ] The project maps to real cloud, DevOps, security, or platform engineering work.
- [ ] The project explains what was configured, validated, secured, and learned.

Portfolio signal:

    I can design, deploy, secure, document, validate, clean up, and explain cloud workloads with evidence.

---

## Final Pre-Push Commands

Run:

    git status --short
    git diff --check
    git ls-files | grep -i '\.DS_Store' || echo "No .DS_Store files tracked"
    gitleaks git .
    trufflehog filesystem . --no-update --results=verified,unknown
    find scripts -name "*.sh" -print -exec bash -n {} \; 2>/dev/null || echo "No shell scripts found"

If all checks pass:

    git add docs/pre-github-checklist.md
    git status --short
    git commit -m "Add pre-GitHub project readiness checklist"
