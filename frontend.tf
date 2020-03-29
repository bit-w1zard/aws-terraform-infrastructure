module "web" {
  source = "../"

  project_name = local.project_name
  environment  = local.environment

  default_root_object = "index.html"
  extra_bucket_policy = data.aws_iam_policy_document.jenkins_web.json

  s3_object_ownership         = "BucketOwnerPreferred"
  s3_control_object_ownership = true

  custom_error_response = [{
    error_code         = "400"
    response_code      = "200"
    response_page_path = "/"
    },
    {
      error_code         = "404"
      response_code      = "200"
      response_page_path = "/"
    },
    {
      error_code         = "405"
      response_code      = "200"
      response_page_path = "/"
    }
  ]

  aliases = [local.frontend_domain]
  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:xyz:certificate/ff7e4929-bba7-4577-8fbc-9adca79c26a9"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }
}
