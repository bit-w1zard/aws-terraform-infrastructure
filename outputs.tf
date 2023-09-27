output "user_pool_name" {
  description = "The name of the User Pool"
  value       = module.user_pool.user_pool.name
}

output "lambda_pretoken_generator_name" {
  description = "The name of the pretoken generator lambda"
  value       = module.pretoken_generator.lambda_function_name
}

output "lambda_custom_message_generator_name" {
  description = "The name of the custom message generator lambda"
  value       = module.custom_message_generator.lambda_function_name
}

output "table_user_pii_name" {
  description = "The name of the user pii table"
  value       = module.user_pii.dynamodb_table_id
}

output "table_user_details_name" {
  description = "The name of the user details table"
  value       = module.user_details.dynamodb_table_id
}

output "table_session_cache_name" {
  description = "The name of the session cache table"
  value       = module.session_cache.dynamodb_table_id
}

output "table_refresh_tokens_name" {
  description = "The name of the refresh tokens table"
  value       = module.refresh_tokens.dynamodb_table_id
}

output "table_code_grant_store_name" {
  description = "The name of the code grant store table"
  value       = module.code_grant_store.dynamodb_table_id
}

output "table_client_apps_name" {
  description = "The name of the client apps table"
  value       = module.client_apps.dynamodb_table_id
}

output "sns_topic_name" {
  description = "The name of the SNS topic"
  value       = aws_sns_topic.sms.id
}

output "ecr_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.app.id
}

output "role_name_oidc" {
  description = "The name of the Role with OIDC"
  value       = "${local.project_name}-${local.environment}-eks-oidc"
}

output "organization_events_sns_topic_arn" {
  value = module.organization_events.sns_topic_arn
}

output "client_credentials_client_id" {
  value = aws_cognito_user_pool_client.client_credentials.id
}

output "client_credentials_client_secret" {
  value = aws_cognito_user_pool_client.client_credentials.client_secret
  sensitive = true
}
