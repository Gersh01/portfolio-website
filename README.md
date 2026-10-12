# Portfolio

A personal portfolio for a cloud / DevOps engineer. The site is plain HTML and CSS. The interesting part is how it ships:

- **Hosting:** a private S3 bucket behind CloudFront (HTTPS, compression, security headers)
- **Infrastructure as code:** everything in [`infra/`](infra/) is Terraform
- **CI/CD:** GitHub Actions validates every change and deploys `main` automatically
- **No stored secrets:** GitHub signs in to AWS with OIDC and a role that can only touch this one bucket and distribution

```
site/                  the website (index.html, styles.css, script.js, 404.html)
infra/                 Terraform: S3, CloudFront, IAM/OIDC, optional ACM + Route 53
.github/workflows/     CI (HTML, placeholders, Terraform) and deploy
```

---

## 1. Fill in your content

Every placeholder is **highlighted in yellow** on the page and marked in the code with `class="todo"` or `TODO`. CI refuses to deploy while any remain, so nothing half-finished reaches a recruiter.

Find what's left (Git Bash, macOS, Linux):

```bash
grep -nE 'class="todo"|TODO' site/index.html
```

When you replace a placeholder, delete the `<span class="todo">` wrapper too. Also:

- Add your résumé as `site/resume.pdf` (CI checks it exists).
- Edit the skills list honestly. Anything listed there is fair game in an interview.
- **Lockheed Martin capstone:** confirm with your advisor or sponsor what you can describe publicly. Talk about the engineering (your role, tools, process, results), not program details.

Tips for project write-ups:

- Lead with whatever is closest to cloud/DevOps: deployed, containerized, automated, monitored.
- Use problem → what you built → result. Numbers help ("cut build time from 12 min to 3").
- Link the repo, and make sure each linked repo has a README with a screenshot and setup steps.

## 2. Preview locally

```bash
python -m http.server 8000 --directory site
```

Then open http://localhost:8000.

## 3. Put it on GitHub

Create a repository (for example `portfolio`) and push this folder to its `main` branch.

## 4. Create the AWS infrastructure (one time)

You need an AWS account, [Terraform](https://developer.hashicorp.com/terraform/install) 1.6+, and the [AWS CLI](https://aws.amazon.com/cli/) signed in as an admin user (`aws configure` or `aws sso login`).

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars   # then set github_repo = "you/portfolio"
terraform init
terraform plan
terraform apply
```

Optional custom domain: register one in Route 53 (roughly $15/year for `.com`), set `domain_name` in `terraform.tfvars`, and apply again. Terraform creates the TLS certificate and DNS records.

## 5. Connect GitHub Actions to AWS

Copy the Terraform outputs into **repository variables** (Settings → Secrets and variables → Actions → Variables). None of them are secret. With the [GitHub CLI](https://cli.github.com/), run from `infra/`:

```bash
gh variable set AWS_DEPLOY_ROLE_ARN --body "$(terraform output -raw github_deploy_role_arn)"
gh variable set AWS_REGION --body "$(terraform output -raw aws_region)"
gh variable set S3_BUCKET --body "$(terraform output -raw s3_bucket)"
gh variable set CLOUDFRONT_DISTRIBUTION_ID --body "$(terraform output -raw cloudfront_distribution_id)"
```

Push to `main` (or run the workflow manually from the Actions tab). The site is live at `terraform output site_url`.

## Cost

Typically **under $1/month** for a portfolio's traffic: S3 storage is pennies, and CloudFront's always-free allowance covers far more traffic than a portfolio gets (check current AWS pricing). A Route 53 hosted zone adds $0.50/month. Set up an [AWS Budget](https://console.aws.amazon.com/billing/home#/budgets) alert at $5 anyway; it's a good habit and a good interview answer.

## Prefer not to use AWS yet?

`site/` is plain static files. It works as-is on GitHub Pages, Netlify, or Cloudflare Pages. You lose the Terraform/OIDC story, which is the part most relevant to DevOps roles.

---

## Interview talking points

Things in this repo you should be ready to explain:

| Decision | Why |
|---|---|
| S3 bucket is private, read through CloudFront Origin Access Control | No public bucket. CloudFront is the only reader, enforced by the bucket policy's `AWS:SourceArn` condition. |
| GitHub → AWS via OIDC, not access keys | Short-lived credentials, nothing to leak or rotate. The trust policy pins the repo and branch. |
| Least-privilege deploy role | It can list/write one bucket and invalidate one distribution. Nothing else. |
| Bucket versioning + 30-day expiry | Roll back a bad deploy by restoring the previous object versions. |
| 403 → 404 error mapping | A private bucket answers 403 for missing keys; CloudFront serves the 404 page instead. |
| CI gates on HTML validation, `terraform fmt`/`validate`, and placeholders | Broken markup, unformatted IaC, or template text can't reach production. |
| `concurrency` group on the workflow | Two pushes can't deploy over each other. |

Natural next steps that also make good résumé lines: remote Terraform state in S3, a `terraform plan` comment on pull requests, a visitor counter with API Gateway + Lambda + DynamoDB, or uptime monitoring with CloudWatch Synthetics.
