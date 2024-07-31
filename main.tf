locals {
  project_id          = var.project_id == "" ? var.project : var.project_id
  s3_bucket_paths_arn = [for path in [var.data_store_path] : "arn:aws:s3:::${replace(path, "s3://", "")}*"]
}


module "crawler_labels" {
  source          = "git::ssh://git@github.mpi-internal.com/datastrategy-mobile-de/terraform-aws-label-deployment.git?ref=tags/0.0.1"
  stage           = var.stage
  project         = var.project
  project_id      = local.project_id
  name            = var.crawler_name
  resource_group  = ""
  resources       = ["role"]
  additional_tags = var.tags
  max_length      = 64
  git_repository  = var.git_repository
}



resource "aws_iam_role" "glue_crawler_role" {
  count = var.enable ? 1 : 0
  name = "${module.crawler_labels.resource["role"]["id"]}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "glue.amazonaws.com",
            "lakeformation.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_crawler_role_policy" {
  count = var.enable ? 1 : 0
  role       = aws_iam_role.glue_crawler_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "lake_formation_permissions" {
  name        = "LakeFormationPermissionsPolicy"
  description = "Policy to allow Lake Formation permissions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lakeformation:GrantPermissions",
          "lakeformation:GetDataAccess",
          "lakeformation:PutDataAccess",
          "lakeformation:BatchGrantPermissions",
          "lakeformation:BatchRevokePermissions",
          "lakeformation:RevokePermissions",
          "lakeformation:DescribeResource",
          "lakeformation:GetResourceLFTags",
          "lakeformation:GetEffectivePermissionsForPath"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lake_formation_permissions_attachment" {
  count = var.enable ? 1 : 0
  role       = aws_iam_role.glue_crawler_role[count.index].name
  policy_arn = aws_iam_policy.lake_formation_permissions.arn
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy to allow Glue Crawler access to S3"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = local.s3_bucket_paths_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  count = var.enable ? 1 : 0
  role       = aws_iam_role.glue_crawler_role[count.index].name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}


resource "aws_glue_crawler" "this" {
  count = var.enable ? 1 : 0
  name = var.crawler_name
  role = aws_iam_role.glue_crawler_role[count.index].arn
  database_name = var.glue_database_name
  table_prefix = var.table_prefix

  dynamic "s3_target" {
    for_each = var.enable_delta_table ? [] : [1]
    content {
      path = var.data_store_path
      exclusions = var.exclusion_pattern
    }
  }

  dynamic "delta_target" {
    for_each = var.enable_delta_table ? [1] : []
    content {
      connection_name = var.connection_name
      create_native_delta_table = true
      delta_tables = var.delta_tables
      write_manifest = var.write_manifest
    }
  }

  schedule = var.crawler_schedule

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }


  depends_on = [
    aws_iam_role.glue_crawler_role,
    aws_iam_role_policy_attachment.glue_crawler_role_policy,
    aws_iam_role_policy_attachment.lake_formation_permissions_attachment,
    aws_iam_role_policy_attachment.s3_access_policy_attachment
  ]
}
