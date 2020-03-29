terraform {
  required_version = ">= 1.0.1"
  backend "s3" {
    bucket         = "production-terraform-state"
    dynamodb_table = "production-terraform-state"
    encrypt        = true
    key            = "xyz/auth/production/terraform.tfstate"
    region         = "eu-central-1"
    profile        = "XXXX_PlatformManagement"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.75.1"
    }
  }
}

provider "aws" {
  region = local.main_region
#  profile = local.profile

  assume_role {
    role_arn     = local.ci_cd_access_role
    session_name = "auth-api"
  }

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "replica"
  region = local.replica_region
#  profile = local.profile

  assume_role {
    role_arn     = local.ci_cd_access_role
    session_name = "auth-api"
  }

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "ca"
  region = local.dynamodb_region[0]
#  profile = local.profile

  assume_role {
    role_arn     = local.ci_cd_access_role
    session_name = "auth-api"
  }

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "us"
  region = local.dynamodb_region[1]
#  profile = local.profile

  assume_role {
    role_arn     = local.ci_cd_access_role
    session_name = "auth-api"
  }

  default_tags {
    tags = local.tags
  }
}
