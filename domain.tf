# Setup custom domain name for API Gateway endpoint
resource "aws_route53_record" "www" {
    name    = aws_api_gateway_domain_name.shortener.domain_name
    type    = "A"
    zone_id = data.aws_route53_zone.sctp_zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.shortener.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.shortener.regional_zone_id
  }
}

resource "aws_api_gateway_domain_name" "shortener" {
  domain_name              = "yap-urlshortener.sctp-sandbox.com"
  regional_certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn # ACM Cert for your domain

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "shortener_domain_mapping" {
    api_id = aws_api_gateway_rest_api.yap_api.id
    stage_name  = aws_api_gateway_stage.api_stage.stage_name
    domain_name = aws_api_gateway_domain_name.shortener.domain_name
}