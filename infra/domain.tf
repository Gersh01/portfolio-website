# Everything in this file is skipped unless var.domain_name is set.
# Assumes the domain's hosted zone already exists in Route 53 (it does automatically
# if you registered the domain through Route 53).

data "aws_route53_zone" "site" {
  count        = local.use_custom_domain ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

resource "aws_acm_certificate" "site" {
  count    = local.use_custom_domain ? 1 : 0
  provider = aws.us_east_1

  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ACM's validation records only exist once the certificate does, so key the records by
# domain name (known at plan time) and look up the record details at apply time.
locals {
  cert_validation_options = {
    for dvo in flatten(aws_acm_certificate.site[*].domain_validation_options) : dvo.domain_name => dvo
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = toset(local.aliases)

  zone_id         = data.aws_route53_zone.site[0].zone_id
  name            = local.cert_validation_options[each.key].resource_record_name
  type            = local.cert_validation_options[each.key].resource_record_type
  records         = [local.cert_validation_options[each.key].resource_record_value]
  ttl             = 300
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "site" {
  count    = local.use_custom_domain ? 1 : 0
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.site[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# A (IPv4) and AAAA (IPv6) alias records for the apex and www.
resource "aws_route53_record" "site" {
  for_each = {
    for pair in setproduct(local.aliases, ["A", "AAAA"]) : "${pair[0]}-${pair[1]}" => {
      name = pair[0]
      type = pair[1]
    }
  }

  zone_id = data.aws_route53_zone.site[0].zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
