output "site_url" {
  description = "Where the site is served."
  value       = local.use_custom_domain ? "https://${var.domain_name}" : "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "s3_bucket" {
  description = "Set as the S3_BUCKET GitHub Actions variable."
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_distribution_id" {
  description = "Set as the CLOUDFRONT_DISTRIBUTION_ID GitHub Actions variable."
  value       = aws_cloudfront_distribution.site.id
}

output "github_deploy_role_arn" {
  description = "Set as the AWS_DEPLOY_ROLE_ARN GitHub Actions variable."
  value       = aws_iam_role.github_deploy.arn
}

output "aws_region" {
  description = "Set as the AWS_REGION GitHub Actions variable."
  value       = var.aws_region
}
