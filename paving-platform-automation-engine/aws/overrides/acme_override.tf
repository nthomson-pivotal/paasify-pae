provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"

  version = "~> 1.2.1"
}

variable "registration_email" {
  type        = "string"
  description = "email will be used to register you with Let's Encrypt"
}

output "cert_pem" {
  value       = acme_certificate.certificate.certificate_pem
  sensitive   = true
  description = "Let's Encrypt managed cert that you provide to your load balancer config"
}

output "private_key_pem" {
  value       = acme_certificate.certificate.private_key_pem
  sensitive   = true
  description = "Let's Encrypt managed cert private key for generated certificate"
}

output "ca_cert_url" {
  value       = acme_certificate.certificate.certificate_url
  description = "Provides the CA and intermediate cert for Let's Encrypt"
}

output "issuer_pem" {
  value = acme_certificate.certificate.issuer_pem
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.registration_email
}

resource "acme_certificate" "certificate" {
  key_type        = "P384"
  account_key_pem = acme_registration.reg.account_key_pem
  common_name     = format("%s.%s", var.env_name, var.dns_suffix)

  subject_alternative_names = [
    format("uaa.%s.%s", var.env_name, var.dns_suffix),
    format("credhub.%s.%s", var.env_name, var.dns_suffix),
    format("plane.%s.%s", var.env_name, var.dns_suffix),
  ]

  dns_challenge {
    provider = "route53"

    config {
      AWS_ACCESS_KEY_ID     = var.access_key
      AWS_SECRET_ACCESS_KEY = var.secret_key
      AWS_HOSTED_ZONE_ID    = aws_route53_zone.hosted_zone.zone_id
    }
  }
}
