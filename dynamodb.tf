module "client_apps" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name     = "${local.project_name}-${local.environment}-client-apps"
  hash_key = "clientId"

  point_in_time_recovery_enabled = true

  attributes = [
    {
      name = "clientId"
      type = "S"
    }
  ]
}

module "code_grant_store" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name     = "${local.project_name}-${local.environment}-code-grant-store"
  hash_key = "codeGrant"

  attributes = [
    {
      name = "codeGrant"
      type = "S"
    },
    {
      name = "userId"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "gsi-userid-index"
      hash_key        = "userId"
      projection_type = "ALL"
    }
  ]

  ttl_enabled        = true
  ttl_attribute_name = "expiresAt"
}

module "refresh_tokens" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name     = "${local.project_name}-${local.environment}-refresh-tokens"
  hash_key = "userId"

  attributes = [
    {
      name = "userId"
      type = "S"
    }
  ]

  ttl_enabled        = true
  ttl_attribute_name = "refreshExpireAt"
}

module "session_cache" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name             = "${local.project_name}-${local.environment}-session-cache"
  hash_key         = "tokenId"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  replica_regions = [for region in local.dynamodb_region :
    {
      region_name = region
    }
  ]

  attributes = [
    {
      name = "tokenId"
      type = "S"
    },
    {
      name = "userId"
      type = "S"
    }
  ]

  ttl_enabled                    = true
  ttl_attribute_name             = "tokenExpiry"
  server_side_encryption_enabled = true

  global_secondary_indexes = [
    {
      name            = "gsi-userid-index"
      hash_key        = "userId"
      projection_type = "ALL"
    }
  ]
}

module "user_details" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name     = "${local.project_name}-${local.environment}-user-details"
  hash_key = "userId"

  point_in_time_recovery_enabled = true

  attributes = [
    {
      name = "userId"
      type = "S"
    }
  ]
}

module "user_pii_ca" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name     = "${local.project_name}-${local.environment}-user-pii"
  hash_key = "userId"

  point_in_time_recovery_enabled = true

  providers = {
    aws = aws.ca
  }
  attributes = [
    {
      name = "userId"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "gsi-email-index"
      hash_key        = "email"
      projection_type = "ALL"
    }
  ]
}

module "user_pii_us" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name     = "${local.project_name}-${local.environment}-user-pii"
  hash_key = "userId"

  point_in_time_recovery_enabled = true

  providers = {
    aws = aws.us
  }

  attributes = [
    {
      name = "userId"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "gsi-email-index"
      hash_key        = "email"
      projection_type = "ALL"
    }
  ]
}

module "user_pii" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name     = "${local.project_name}-${local.environment}-user-pii"
  hash_key = "userId"

  point_in_time_recovery_enabled = true

  attributes = [
    {
      name = "userId"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "gsi-email-index"
      hash_key        = "email"
      projection_type = "ALL"
    }
  ]
}

module "organizations" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name             = "${local.project_name}-${local.environment}-organizations"
  hash_key         = "id"
  stream_enabled   = true
  stream_view_type = "KEYS_ONLY"

  point_in_time_recovery_enabled = true

  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "createdBy"
      type = "S"
    },
    {
      name = "normalizedName"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "gsi-created-by-index"
      hash_key        = "createdBy"
      projection_type = "ALL"
    },
    {
      name            = "gsi-normalized-name-index"
      hash_key        = "normalizedName"
      projection_type = "ALL"
    }
  ]
}

module "migration" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name     = "${local.project_name}-${local.environment}-migration"
  hash_key = "migrationId"

  point_in_time_recovery_enabled = true

  attributes = [
    {
      name = "migrationId"
      type = "S"
    }
  ]
}

resource "aws_dynamodb_table" "organization-member" {
  name         = "${local.project_name}-${local.environment}-organization-member"
  hash_key     = "organizationId"
  range_key    = "email"
  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "organizationId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "invitationId"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi-userid-index"
    hash_key        = "userId"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "email-userid-index"
    hash_key        = "email"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "gsi-invitationid-index"
    hash_key        = "invitationId"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "organization-member-ca" {
  name         = "${local.project_name}-${local.environment}-organization-member"
  hash_key     = "organizationId"
  range_key    = "email"
  billing_mode = "PAY_PER_REQUEST"

  provider = aws.ca

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "organizationId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "invitationId"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi-userid-index"
    hash_key        = "userId"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "email-userid-index"
    hash_key        = "email"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "gsi-invitationid-index"
    hash_key        = "invitationId"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "organization-member-us" {
  name         = "${local.project_name}-${local.environment}-organization-member"
  hash_key     = "organizationId"
  range_key    = "email"
  billing_mode = "PAY_PER_REQUEST"

  provider = aws.us

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "organizationId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "invitationId"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi-userid-index"
    hash_key        = "userId"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "email-userid-index"
    hash_key        = "email"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "gsi-invitationid-index"
    hash_key        = "invitationId"
    projection_type = "ALL"
  }
}
