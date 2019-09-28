output "ssl_cert" {
  value = tls_self_signed_cert.ssl_cert.cert_pem
}

output "ssl_private_key" {
  sensitive = true
  value     = tls_private_key.ssl_private_key.private_key_pem
}

resource "tls_private_key" "ssl_private_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "ssl_cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.ssl_private_key.private_key_pem

  dns_names = [
    "uaa.${var.env_name}.${var.dns_suffix}",
    "credhub.${var.env_name}.${var.dns_suffix}",
    "plane.${var.env_name}.${var.dns_suffix}",
  ]

  validity_period_hours = 8760 # 1year

  subject {
    common_name         = format("%s.%s", var.env_name, var.dns_suffix)
    organization        = "Pivotal"
    organizational_unit = "Cloudfoundry"
    country             = "US"
    province            = "CA"
    locality            = "San Francisco"
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
