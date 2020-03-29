module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.9.0"

  bucket = "${local.project_name}-${local.environment}-lambda"

  policy        = data.aws_iam_policy_document.jenkins_lambda.json
  attach_policy = true

  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning = {
    enabled = true
  }
}

data "aws_s3_bucket_object" "s3_object" {
  bucket = module.s3.s3_bucket_id
  key    = local.lambda_artifact_key
}

module "custom_message_generator" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.17.0"

  function_name = "${local.project_name}-${local.environment}-custom-message-generator"

  s3_existing_package = {
    bucket  = data.aws_s3_bucket_object.s3_object.bucket
    key     = data.aws_s3_bucket_object.s3_object.key
    version = data.aws_s3_bucket_object.s3_object.version_id
  }

  create_package                          = false
  timeout                                 = 15
  memory_size                             = 512
  handler                                 = "com.xyz.auth.lambda.trigger.PostSignUpCustomMessageTrigger::handleRequest"
  runtime                                 = "java11"
  create_current_version_allowed_triggers = false
  ignore_source_code_hash                 = true

  environment_variables = {
    accountConfirmationEndpoint = "https://${local.api_domain}/api/sso/v1/registration/confirmation"
  }

  allowed_triggers = {
    CustomMessageAllowExecutionFromCognito = {
      service    = "cognito-idp"
      source_arn = module.user_pool.user_pool.arn
    }
  }
}

module "pretoken_generator" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.17.0"

  function_name = "${local.project_name}-${local.environment}-pretoken-generator"

  policy_json        = data.aws_iam_policy_document.pretoken_lambda.json
  attach_policy_json = true

  s3_existing_package = {
    bucket  = data.aws_s3_bucket_object.s3_object.bucket
    key     = data.aws_s3_bucket_object.s3_object.key
    version = data.aws_s3_bucket_object.s3_object.version_id
  }

  environment_variables = {
    WORKSPACE = "${local.project_name}-${local.environment}"
  }

  create_package                          = false
  timeout                                 = 15
  memory_size                             = 512
  handler                                 = "com.xyz.auth.lambda.trigger.PretokenGenerationLambdaTrigger::handleRequest"
  runtime                                 = "java11"
  ignore_source_code_hash                 = true
  create_current_version_allowed_triggers = false

  allowed_triggers = {
    PreTokenAllowExecutionFromCognito = {
      service    = "cognito-idp"
      source_arn = module.user_pool.user_pool.arn
    }
  }
}
