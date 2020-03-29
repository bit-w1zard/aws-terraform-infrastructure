resource "aws_ssm_parameter" "region" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/region"
  type  = "SecureString"
  value = local.main_region
  overwrite = true
}

resource "aws_ssm_parameter" "region_replica" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/region/replica"
  type  = "SecureString"
  value = local.replica_region
  overwrite = true
}

resource "aws_ssm_parameter" "cognito_clientid" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/cognito/client/id"
  type  = "SecureString"
  value = module.user_pool.clients["${local.project_name}-${local.environment}-user-pool-client"].id
  overwrite = true
}

resource "aws_ssm_parameter" "cognito_client_secret" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/cognito/client/secret"
  type  = "SecureString"
  value = module.user_pool.client_secrets["${local.project_name}-${local.environment}-user-pool-client"]
  overwrite = true
}

resource "aws_ssm_parameter" "client_credentials_client_id" {
  name     = "/${replace(local.project_name, "-", "/")}/${local.environment}/cognito/client/m2m-client-id"
  type     = "SecureString"
  value    = aws_cognito_user_pool_client.client_credentials.id
}

resource "aws_ssm_parameter" "client_credentials_client_secret" {
  name     = "/${replace(local.project_name, "-", "/")}/${local.environment}/cognito/client/m2m-client-secret"
  type     = "SecureString"
  value    = aws_cognito_user_pool_client.client_credentials.client_secret
}

resource "aws_ssm_parameter" "cognito_poolid" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/cognito/poolid"
  type  = "SecureString"
  value = module.user_pool.user_pool.id
  overwrite = true
}

resource "aws_ssm_parameter" "jwk_url" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/cognito/jwk/url"
  type  = "SecureString"
  value = "https://cognito-idp.${local.main_region}.amazonaws.com/${module.user_pool.user_pool.id}/.well-known/jwks.json"
  overwrite = true
}

resource "aws_ssm_parameter" "ses_region" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/ses/region"
  type  = "SecureString"
  value = "us-east-1"
  overwrite = true
}

resource "aws_ssm_parameter" "ses_email" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/ses/email"
  type  = "SecureString"
  value = local.email
  overwrite = true
}

resource "aws_ssm_parameter" "auth_endpoint" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/auth/endpoint"
  type  = "SecureString"
  value = "https://${local.frontend_domain}/login"
  overwrite = true
}

resource "aws_ssm_parameter" "auth_domain" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/cookie/domain"
  type  = "SecureString"
  value = local.cookie_domain
  overwrite = true
}

resource "aws_ssm_parameter" "frontend_domain" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/frontend/domain"
  type  = "SecureString"
  value = "https://${local.frontend_domain},  https://${local.marketplace_domain}"
  overwrite = true
}

resource "aws_ssm_parameter" "prefix_name" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/prefix/name"
  type  = "SecureString"
  value = "${local.project_name}-${local.environment}"
  overwrite = true
}

resource "aws_ssm_parameter" "prefix_enabled" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/prefix/enabled"
  type  = "SecureString"
  value = "true"
  overwrite = true
}

resource "aws_ssm_parameter" "refresh_token" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/refresh/token/expiry"
  type  = "SecureString"
  value = "30"
  overwrite = true
}

resource "aws_ssm_parameter" "auth_web_client_id" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/web/client/id"
  type  = "SecureString"
  value = local.auth_web_client_id
  overwrite = true
}

resource "aws_ssm_parameter" "payments_endpoint" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/payments/endpoint"
  type  = "SecureString"
  value = local.payments_endpoint
  overwrite = true
}

resource "aws_ssm_parameter" "cognito_endpoint" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/cognito/endpoint"
  type  = "SecureString"
  value = local.cognito_endpoint
  overwrite = true
}

resource "aws_ssm_parameter" "organization_events_topic_arn" {
  name  = "/${replace(local.project_name, "-", "/")}/${local.environment}/organization/events/topic/arn"
  type  = "SecureString"
  value = module.organization_events.sns_topic_arn
  overwrite = true
}
