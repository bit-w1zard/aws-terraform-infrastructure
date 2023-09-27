locals {
  profile = "xyz-PlatformManagement"

  main_region     = "eu-central-1"
  replica_region  = "eu-west-1"
  dynamodb_region = ["ca-central-1", "us-east-1"]

  project_name = "xyz-authentication"
  cluster_name = "services"
  environment  = "production"

  marketplace_account_id = "XXXX"
  lambda_project_name    = "xyz-lambdas"

  frontend_domain = "auth.abc.com"
  cookie_domain   = local.api_domain
  api_domain      = "auth-api.${local.sso_domain}"
  sso_domain      = "abc.com"

  marketplace_domain  = "marketplace.abc.eu"
  email               = "support@abc.com"
  email_source_arn    = "arn:aws:ses:us-east-1:XXXX:identity/${local.email}"
  sms_external_id     = "XXXXX"
  file_name           = "./../../auth-service-lambdas/build/libs/auth-lambdas.jar"
  lambda_artifact_key = "auth-lambdas.jar"
  jenkins_role_arn    = ["arn:aws:iam::XXXX:role/system_manager_rolejenkins-central"]
  ci_cd_access_role   = "arn:aws:iam::XXXX:role/Jenkins-CI-CD-access"
  marketplace_account_events_subscription_endpoint = "https://marketplaceapi.xyz.eu/api/v1/xyz/payments/webhooks"

  workspace_prefix          = (terraform.workspace == "default") ? "" : "${terraform.workspace}-"
  account_updated_topic_arn = data.aws_sns_topic.payment-account-events.arn
  payments_project_name     = "xyz-payments"

  # This role will be added to the KMS and only this role can delete KMS key
  admin_role_arn = "arn:aws:iam::XXXX:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_d759a17fd0563156"

  # List of roles that will be provided an access to the EKS cluster
  list_roles = [
    "arn:aws:iam::XXXX:role/AWSReservedSSO_PlatformManagement_ad9397a7b0786f44",
    "arn:aws:iam::XXXX:role/AWSReservedSSO_AdministratorAccess_d759a17fd0563156",
    "arn:aws:iam::XXXX:role/Jenkins-CI-CD-access"
  ]

  worker_groups_launch_template_main = [
    {
      name          = "on-demand-group"
      instance_type = "c5.xlarge"
    },
    {
      name                     = "spot-group"
      override_instance_types  = ["c5a.2xlarge", "c5.2xlarge", "c5d.2xlarge"]
      kubelet_extra_args       = "--node-labels=lifecycle=spot --register-with-taints=workload=dedicated:NoSchedule"
      spot_allocation_strategy = "capacity-optimized"
      spot_instance_pools      = 0
      asg_min_size             = 2
    }
  ]

  worker_groups_launch_template_replica = [
    {
      name = "on-demand-group"
      # Change `t3.small` to `c5.xlarge` when you need scale cluster back
      instance_type = "t3.small"
      # The replica cluster has been scaled to 1
      # Change it when you need scale cluster back
      asg_max_size         = 1
      asg_min_size         = 1
      asg_desired_capacity = 1
    },
    {
      name                     = "spot-group"
      override_instance_types  = ["c5a.2xlarge", "c5.2xlarge", "c5d.2xlarge"]
      kubelet_extra_args       = "--node-labels=lifecycle=spot --register-with-taints=workload=dedicated:NoSchedule"
      spot_allocation_strategy = "capacity-optimized"
      spot_instance_pools      = 0
      # The replica cluster has been scaled to 0
      # Change it when you need scale cluster back
      asg_max_size         = 0
      asg_min_size         = 0
      asg_desired_capacity = 0
    }
  ]

  # List of policies will be added to the worker nodes IAM role
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
  ]

  tags = {
    "Project"                    = "xyz"
    "Environment"                = local.environment
    "SaaS"                       = "true"
    "Application:authentication" = "true"
    "Application:payment"        = "true"
    "Owner"                      = "Terraform"
    "Team"                       = "shared-services"
    "Service"                    = "authentication"
  }

  asg_tags = [for key, value in local.tags :
    {
      key                 = key
      value               = value
      propagate_at_launch = true
    }
  ]
  auth_web_client_id = "prod-auth-web-client"
  payments_endpoint  = "https://payments-api.abc.com/api/payments/v1"
  cognito_endpoint  = "https://xyz-auth-production.auth.eu-central-1.amazoncognito.com"
}
