# portfolio-website

Source for my portfolio site: static HTML and CSS on AWS, with the infrastructure defined in Terraform and deploys run by GitHub Actions.

```
git push → GitHub Actions → (OIDC) IAM role → S3 (private, versioned) → CloudFront → HTTPS
```

| Path | Contents |
|---|---|
| `site/` | The site itself. No build step. |
| `infra/` | Terraform: S3, CloudFront with Origin Access Control, GitHub OIDC provider and deploy role, optional ACM certificate and Route 53 records |
| `.github/workflows/deploy.yml` | Checks every push and pull request; deploys `main` |

## Design notes

- **Private bucket.** CloudFront reads it through Origin Access Control, and the bucket policy only allows requests carrying this distribution's ARN.
- **No stored AWS keys.** GitHub Actions authenticates with OIDC. The deploy role trusts only this repository's `main` branch and can only write to this bucket and invalidate this distribution.
- **Rollback.** Bucket versioning keeps previous deploys; noncurrent versions expire after 30 days.
- **404s.** S3 returns 403 for missing keys on a private bucket, so CloudFront maps both 403 and 404 to `404.html`.
- **Deploy stamp.** The deploy job writes the commit SHA and date into the footer, so the live site shows exactly which commit it's running.
- **No overlapping deploys.** The workflow uses a `concurrency` group.

## CI checks

| Check | Runs on |
|---|---|
| HTML validation (`html-validate`) | every push and PR |
| No `TODO` markers in `site/` | every push and PR |
| `site/resume.pdf` exists | every push and PR |
| `terraform fmt -check` and `terraform validate` | every push and PR |
| Sync to S3 and invalidate CloudFront | pushes to `main` only, after the checks pass |

## Local preview

```bash
python -m http.server 8000 --directory site
```

## Provisioning

Requires an AWS account, Terraform 1.6+, and the AWS CLI with admin credentials for the initial apply.

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars   # set github_repo, and domain_name if using one
terraform init
terraform apply
```

Then set the deploy settings as GitHub Actions repository variables (none are secret):

```bash
gh variable set AWS_DEPLOY_ROLE_ARN --body "$(terraform output -raw github_deploy_role_arn)"
gh variable set AWS_REGION --body "$(terraform output -raw aws_region)"
gh variable set S3_BUCKET --body "$(terraform output -raw s3_bucket)"
gh variable set CLOUDFRONT_DISTRIBUTION_ID --body "$(terraform output -raw cloudfront_distribution_id)"
```

After that, every push to `main` deploys.

## Cost

Under $1/month at portfolio traffic levels. A Route 53 hosted zone adds $0.50/month when using a custom domain.
