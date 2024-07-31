# Terraform Module: AWS Glue Crawlers

This Terraform module facilitates the automated deployment and management of AWS Glue crawlers. It's designed to handle both standard data sources and Delta tables, providing flexibility for various data management scenarios. The module includes conditional logic to ensure resources are created only when necessary and integrates an external script to check for the existence of Glue databases, thus avoiding failures during Terraform runs.

### Features
- **Automated Glue Crawler Management**: Deploys AWS Glue crawlers with all necessary configurations, managing them throughout their lifecycle.
- **Conditional Database Creation**: Checks for the existence of a Glue database and creates it if it does not already exist, using an external bash script for robust existence checks.
- **Delta Table Support**: Optionally configures crawlers to handle Delta tables, including settings for connection names, table paths, and manifest writing.
- **Scheduling**: Allows specifying cron schedules for crawler executions to automate data scanning processes.
- **IAM Role Handling**: Automatically creates and configures IAM roles with appropriate permissions, managed through an external Terraform module for labeling and consistent naming conventions.
- **Modular and Reusable**: Designed to be used across multiple environments or projects with adjustable parameters.

### Module Usage

(notice usage of the repo path of the module + tag version)

```hcl
########################################################################################################################
# Glue Crawler Module
########################################################################################################################
module "glue_crawler" {
  source = "git::ssh://git@github.mpi-internal.com/datastrategy-mobile-de/terraform-aws-glue-crawler-deployment.git?ref=tags/0.0.1"

  enable                  = true
  crawler_name            = "tf-delta-crawler"
  glue_database_name      = "tf-delta-db"

  data_store_path         = "s3://mo-delta-ad-view-events-730335331410-eu-central-1/ad-view/"
  table_prefix            = "delta_"
  # exclusion_pattern      = ["**/temporary/**", "**/backup/**"]

  crawler_schedule        = "cron(0 12 * * ? *)"

  # Optional Inputs for Delta tables
  enable_delta_table      = true
  connection_name         = ""
  create_native_delta_table = true
  delta_tables            = ["s3://mo-delta-ad-view-events-730335331410-eu-central-1/ad-view/"]
  write_manifest          = false

  stage                   = "dev"
  project                 = var.project
  project_id              = var.project_id

  git_repository          = var.git_repository

  depends_on = [aws_glue_catalog_database.this]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_crawler_labels"></a> [crawler\_labels](#module\_crawler\_labels) | git::ssh://git@github.mpi-internal.com/datastrategy-mobile-de/terraform-aws-label-deployment.git?ref=tags/0.0.1 |  |

## Resources

| Name | Type |
|------|------|
| [aws_glue_catalog_database.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_crawler.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |
| [aws_iam_policy.lake_formation_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.glue_crawler_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.glue_crawler_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lake_formation_permissions_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_access_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [data.external.check_glue_database](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable"></a> [enable](#input\_enable) | Whether to create the stack in this module or not. | `bool` | `true` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage of the Stack (dev/int/prd) | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID used for billing | `string` | `"Not Set"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Instance specific Tags | `map(string)` | `{}` | no |
| <a name="input_git_repository"></a> [git\_repository](#input\_git_repository) | Repository where the infrastructure was deployed from. | `string` | n/a | yes |
| <a name="input_crawler_name"></a> [crawler\_name](#input\_crawler\_name) | The name of the Glue crawler | `string` | n/a | yes |
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | The name of the Glue database where the results are stored | `string` | n/a | yes |
| <a name="input_table_prefix"></a> [table\_prefix](#input\_table\_prefix) | The table prefix used for catalog tables that are created | `string` | `""` | no |
| <a name="input_data_store_path"></a> [data\_store_path](#input\_data\_store\_path) | S3 path where the data or Delta tables are stored | `string` | n/a | yes |
| <a name="input_crawler_schedule"></a> [crawler\_schedule](#input\_crawler\_schedule) | The schedule for the crawler (cron or rate expression) | `string` | `"cron(0 12 * * ? *)"` | no |
| <a name="input_exclusion_pattern"></a> [exclusion\_pattern](#input\_exclusion\_pattern) | A list of glob patterns used to exclude from the crawl. | `list(string)` | `[]` | no |
| <a name="input_enable_delta_table"></a> [enable\_delta\_table](#input\_enable\_delta\_table) | Enable crawler configuration for Delta tables | `bool` | `false` | no |
| <a name="input_connection_name"></a> [connection\_name](#input\_connection\_name) | The name of the connection to use to connect to the Delta table target (required if Delta tables are enabled) | `string` | `""` | no |
| <a name="input_create_native_delta_table"></a> [create\_native\_delta\_table](#input\_create\_native\_delta\_table) | Specifies whether the crawler will create native tables (required if Delta tables are enabled) | `bool` | `true` | no |
| <a name="input_delta_tables"></a> [delta\_tables](#input\_delta\_tables) | List of S3 paths to the Delta tables (required if Delta tables are enabled) | `list(string)` | `[]` | no |
| <a name="input_write_manifest"></a> [write\_manifest](#input\_write\_manifest) | Specifies whether to write the manifest files to the Delta table path (required if Delta tables are enabled) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_crawler_arn"></a> [crawler\_arn](#output\_crawler\_arn) | ARN of the Glue crawler |
| <a name="output_crawler_name"></a> [crawler\_name](#output\_crawler\_name) | Name of the Glue crawler |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether the stack is enabled |

<!-- END_TF_DOCS -->