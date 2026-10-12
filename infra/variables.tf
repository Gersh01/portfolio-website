variable "aws_region" {
  description = "Region for the S3 bucket and IAM resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used to prefix resource names."
  type        = string
  default     = "portfolio"
}

variable "github_repo" {
  description = "GitHub repository allowed to deploy, as \"owner/repo\" (case-sensitive)."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repo))
    error_message = "Use the form \"owner/repo\", e.g. \"janedoe/portfolio\"."
  }
}

variable "github_branch" {
  description = "Only workflows running on this branch can assume the deploy role."
  type        = string
  default     = "main"
}

variable "create_github_oidc_provider" {
  description = "Set to false if this AWS account already has the GitHub Actions OIDC provider (an account can only have one)."
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Optional apex domain (e.g. \"janedoe.dev\") with an existing Route 53 hosted zone. Leave empty to use the CloudFront URL."
  type        = string
  default     = ""
}
