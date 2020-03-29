module "organization_events" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 3.0"

  name = "${local.project_name}-${local.environment}-organization-events"
}

resource "aws_sns_topic_subscription" "marketplace-account-events-subscription" {
  topic_arn     = module.organization_events.sns_topic_arn
  protocol      = "https"
  endpoint      = local.marketplace_account_events_subscription_endpoint
  filter_policy = jsonencode(tomap({"eventType": tolist(["UPDATE", "CREATE"])}))
}

resource "aws_sns_topic_policy" "organization_events_policy" {
  arn = module.organization_events.sns_topic_arn

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        Sid : "__default_statement_ID",
        Effect : "Allow",
        Principal : {
          "AWS" : "*"
        },
        Action : [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish"
        ],
        Resource : module.organization_events.sns_topic_arn,
        Condition : {
          "StringEquals" : {
            "AWS:SourceOwner" : data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
