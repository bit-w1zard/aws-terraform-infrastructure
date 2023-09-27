data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_eks_cluster" "this" {
  name = "${local.cluster_name}-${local.environment}"
  provider = aws
}

data "aws_eks_cluster" "replica" {
  name = "${local.cluster_name}-${local.environment}-ha"
  provider = aws.replica
}

data "aws_iam_policy_document" "assume_role_with_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.project_name}-${local.environment}:auth"]
    }
  }
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.replica.identity[0].oidc[0].issuer, "https://", "")}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.replica.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.project_name}-${local.environment}:auth"]
    }
  }
  provider = aws
}

data "aws_iam_policy_document" "pretoken_lambda" {
  statement {
    sid = "SpecificTable"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:dynamodb:${local.main_region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-user-details",
      "arn:${data.aws_partition.current.partition}:dynamodb:${local.main_region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-organizations",
      "arn:${data.aws_partition.current.partition}:dynamodb:${local.main_region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-organizations/index/*",
    ]
  }
}

data "aws_iam_policy_document" "oidc_eks" {
  statement {
    sid = "SpecificTable"

    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem",
    ]
    resources = flatten([for region in concat([local.main_region], local.dynamodb_region) :
      [
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-client-apps",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-code-grant-store",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-refresh-tokens",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-session-cache",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-user-details",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-user-pii",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-organizations",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-migration",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-client-apps/index/*",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-code-grant-store/index/*",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-refresh-tokens/index/*",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-session-cache/index/*",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-user-details/index/*",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-user-pii/index/*",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-organizations/index/*"
    ]])
  }

  statement {
    sid = "AccessToTheSSM"

    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/Service"
      values   = ["authentication"]
    }

    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/Shared"
      values   = ["true"]
    }

    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/Environment"
      values   = [local.environment]
    }
  }

  statement {
    sid = "CognitoAdminAuth"

    actions = [
      "cognito-idp:AdminInitiateAuth",
      "cognito-idp:AdminUpdateUserAttributes",
      "cognito-idp:AdminSetUserMFAPreference",
      "cognito-idp:AdminDeleteUserAttributes",
      "cognito-idp:AdminConfirmSignUp",
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminSetUserPassword"
    ]
    resources = [
      "${module.user_pool.user_pool.arn}",
    ]
  }

  statement {
    sid = "AccessToSES"

    actions = [
      "ses:*"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid = "AccessToSNS"

    actions = [
      "sns:*"
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "sms_publisher_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [local.sms_external_id]
    }
  }
}

data "aws_iam_policy_document" "sms_publisher" {
  statement {
    sid       = "AllowSNSPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "jenkins_web" {
  statement {
    sid    = "AllowJenkins"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads"
    ]
    principals {
      type        = "AWS"
      identifiers = local.jenkins_role_arn
    }
    resources = [
      module.web.s3_bucket_arn,
      "${module.web.s3_bucket_arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "jenkins_lambda" {
  statement {
    sid    = "AllowJenkins"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads"
    ]
    principals {
      type        = "AWS"
      identifiers = local.jenkins_role_arn
    }
    resources = [
      module.s3.s3_bucket_arn,
      "${module.s3.s3_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "kmp_shared_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.read_access_to_dynamodb.json,
    data.aws_iam_policy_document.access_to_secret_manager.json
  ]
}
data "aws_iam_policy_document" "kmp_trust_entity" {

  statement {
    sid = "MarketplaceTrust"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.marketplace_account_id}:role/kmp-access-to-auth-production"]
    }
  }
}

data "aws_iam_policy_document" "read_access_to_dynamodb" {
  statement {
    sid = "SpecificTable"

    actions = [
      "dynamodb:Get*"
    ]

    resources = flatten([for region in concat([local.main_region], local.dynamodb_region) :
      [
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-session-cache",
        "arn:${data.aws_partition.current.partition}:dynamodb:${region}:${data.aws_caller_identity.current.account_id}:table/${local.project_name}-${local.environment}-session-cache/index/*"
    ]])
  }
}

data "aws_iam_policy_document" "access_to_secret_manager" {
  statement {
    sid = "AccessToTheSSM"

    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/Service"
      values   = ["authentication"]
    }

    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/Environment"
      values   = [local.environment]
    }

    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/ClientApp"
      values   = ["marketplace"]
    }
  }
}

data "aws_lambda_function" "create_auth_challenge_lambda" {
  function_name = "${local.lambda_project_name}-${local.environment}-create-auth-challenge"
}

data "aws_lambda_function" "define_auth_challenge_lambda" {
  function_name = "${local.lambda_project_name}-${local.environment}-define-auth-challenge"
}

data "aws_lambda_function" "verify_auth_challenge_lambda" {
  function_name = "${local.lambda_project_name}-${local.environment}-verify-auth-challenge"
}

data "aws_lambda_function" "pretoken_generation_lambda" {
  function_name = "${local.lambda_project_name}-${local.environment}-pretoken-generation"
}

data "aws_sns_topic" "payment-account-events" {
  name = "${local.workspace_prefix}${local.payments_project_name}-${local.environment}-account-events"
}
