module "user_pool" {
  source  = "mineiros-io/cognito-user-pool/aws"
  version = "0.8.0"

  name                = "${title(local.environment)} Authorization User Pool"
  username_attributes = ["email"]
  auto_verified_attributes = [
    "email",
    "phone_number"
  ]
  schema_attributes = [
    {
      name       = "email"
      type       = "String"
      required   = true
      mutable    = true
      max_length = "2048"
      min_length = "0"
    },
    {
      name       = "preferred_username"
      type       = "String"
      required   = true
      mutable    = false
      max_length = "2048"
      min_length = "0"
    }
  ]

  password_minimum_length          = 8
  temporary_password_validity_days = 7
  password_require_numbers         = false
  password_require_symbols         = false
  password_require_lowercase       = false
  password_require_uppercase       = false

  allow_admin_create_user_only = false
  invite_email_message         = "Your username is {username} and temporary password is {####}. "
  invite_email_subject         = "Your temporary password"
  invite_sms_message           = "Your username is {username} and temporary password is {####}. "
  sms_authentication_message   = "Your verification code is {####}. "
  email_source_arn             = local.email_source_arn
  email_from_address           = "xyz Support <${local.email}>"
  email_sending_account        = "DEVELOPER"
  email_message                = "Your verification code is {####}. "
  email_message_by_link        = "Please click the link below to verify your email address. {##Verify Email##} "
  email_subject                = "Your verification code"
  email_subject_by_link        = "Your verification link"
  default_email_option         = "CONFIRM_WITH_CODE"
  sms_message                  = "Your verification code is {####}. "

  account_recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]

  lambda_custom_message       = module.custom_message_generator.lambda_function_arn
  lambda_pre_token_generation = data.aws_lambda_function.pretoken_generation_lambda.arn
  lambda_define_auth_challenge = data.aws_lambda_function.define_auth_challenge_lambda.arn
  lambda_verify_auth_challenge_response = data.aws_lambda_function.verify_auth_challenge_lambda.arn
  lambda_create_auth_challenge = data.aws_lambda_function.create_auth_challenge_lambda.arn

  sms_configuration = {
    external_id    = local.sms_external_id
    sns_caller_arn = aws_iam_role.sms_publisher.arn
  }

  clients = [{
    name                          = "${local.project_name}-${local.environment}-user-pool-client"
    access_token_validity         = 15
    id_token_validity             = 15
    generate_secret               = true
    enable_token_revocation       = true
    prevent_user_existence_errors = "ENABLED"
    callback_urls                 = ["https://${local.api_domain}"]
    logout_urls                   = ["https://${local.api_domain}/logout"]
    supported_identity_providers  = ["COGNITO"]
    allowed_oauth_flows           = ["code"]
    token_validity_units = {
      refresh_token = "days"
      access_token  = "minutes"
      id_token      = "minutes"
    }
    allowed_oauth_scopes = [
      "phone",
      "email",
      "openid",
      "profile",
      "aws.cognito.signin.user.admin"
    ]
    allowed_oauth_scopes = [
      "phone",
      "email",
      "openid",
      "profile",
      "aws.cognito.signin.user.admin"
    ]
    explicit_auth_flows = [
      "ALLOW_ADMIN_USER_PASSWORD_AUTH",
      "ALLOW_CUSTOM_AUTH",
      "ALLOW_USER_PASSWORD_AUTH",
      "ALLOW_USER_SRP_AUTH",
      "ALLOW_REFRESH_TOKEN_AUTH"
    ]
    }
  ]

  domain = "${local.project_name}-${local.environment}"

  allow_software_mfa_token = false
  user_device_tracking     = "OFF"
}

resource "aws_cognito_resource_server" "shared_services_resource_server" {
  identifier   = "shared-services"
  name         = "shared-services"
  user_pool_id = module.user_pool.user_pool.id

  depends_on = [module.user_pool]

  scope {
    scope_name        = "service"
    scope_description = "Generic role for m2m communication"
  }
}

resource "aws_cognito_user_pool_client" "client_credentials" {
  name                                 = "${terraform.workspace}-client-credentials"
  user_pool_id                         = module.user_pool.user_pool.id
  generate_secret                      = true
  allowed_oauth_flows                  = ["client_credentials"]
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.shared_services_resource_server.scope_identifiers

  depends_on = [
    module.user_pool,
    aws_cognito_resource_server.shared_services_resource_server
  ]
}
