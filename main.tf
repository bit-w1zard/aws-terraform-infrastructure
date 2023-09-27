# ECR repo for two regions
resource "aws_ecr_repository" "app" {
  name = "${local.project_name}-${local.environment}-service"

  provider = aws
}

# Create SNS topic
resource "aws_sns_topic" "sms" {
  name = "${local.project_name}-${local.environment}-sms"
}

# Create role for Cognito
resource "aws_iam_role" "sms_publisher" {
  name               = "${local.project_name}-${local.environment}-sms-publisher"
  assume_role_policy = data.aws_iam_policy_document.sms_publisher_assume.json
}

resource "aws_iam_role_policy" "sms_publisher" {
  name   = "${local.project_name}-${local.environment}-sms-publisher"
  role   = aws_iam_role.sms_publisher.id
  policy = data.aws_iam_policy_document.sms_publisher.json
}

# Create OIDC roles for two clusters
resource "aws_iam_role" "oidc_eks_role" {
  name               = "${local.project_name}-${local.environment}-eks-oidc"
  assume_role_policy = data.aws_iam_policy_document.assume_role_with_oidc.json

  provider = aws
}

resource "aws_iam_role_policy" "oidc_eks_role" {
  name   = "${local.project_name}-${local.environment}-resources-access"
  role   = aws_iam_role.oidc_eks_role.id
  policy = data.aws_iam_policy_document.oidc_eks.json

  provider = aws
}

resource "aws_iam_role" "kmp_shared_role" {
  name               = "${local.project_name}-${local.environment}-shared-role"
  assume_role_policy = data.aws_iam_policy_document.kmp_trust_entity.json
}

resource "aws_iam_policy" "kmp_shared_role" {
  name   = "${local.project_name}-${local.environment}-shared-policy"
  policy = data.aws_iam_policy_document.kmp_shared_policy.json
}


resource "aws_iam_role_policy_attachment" "kmp_shared_role" {
  role       = aws_iam_role.kmp_shared_role.name
  policy_arn = aws_iam_policy.kmp_shared_role.arn
}
