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


