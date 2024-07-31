# variables.tf

variable "enable" {
  description = "Whether to create the stack in this module or not."
  type        = bool
  default     = true
}

variable "stage" {
  description = "Stage of the Stack (dev/pre/prd)"
}

variable "project" {}

variable "project_id" {
  type        = string
  default     = "Not Set"
  description = "ID used for billing"
}


variable "tags" {
  description = "Instance specific Tags"
  type        = map(string)
  default     = {}
}


variable "git_repository" {
  type        = string
  description = "Repository where the infrastructure was deployed from."
}


variable "crawler_name" {
  description = "The name of the Glue crawler"
  type        = string
}

variable "glue_database_name" {
  description = "The name of the Glue database where the results are stored"
  type        = string
}


variable "table_prefix" {
  description = "The table prefix used for catalog tables that are created"
  type        = string
  default     = ""
}

variable "data_store_path" {
  description = "S3 path where the data or Delta tables are stored"
  type        = string
  default     = ""
}

variable "crawler_schedule" {
  description = "The schedule for the crawler (cron or rate expression)"
  type        = string
  default     = "cron(0 12 * * ? *)" // Every day at noon UTC
}


variable "exclusion_pattern" {
  description = "A list of glob patterns used to exclude from the crawl."
  type        = list(string)
  default     = [] # Set default to an empty list if no exclusions are initially needed
}

## Optional Delta table configurations

variable "enable_delta_table" {
  description = "Enable crawler configuration for Delta tables"
  type        = bool
  default     = false
}

variable "connection_name" {
  description = "The name of the connection to use to connect to the Delta table target (required if Delta tables are enabled)"
  type        = string
  default     = ""
}

variable "create_native_delta_table" {
  description = "Specifies whether the crawler will create native tables (required if Delta tables are enabled)"
  type        = bool
  default     = true # Set to true if you want native table creation by default
}

variable "delta_tables" {
  description = "List of S3 paths to the Delta tables (required if Delta tables are enabled)"
  type        = list(string)
  default     = []
}

variable "write_manifest" {
  description = "Specifies whether to write the manifest files to the Delta table path (required if Delta tables are enabled)"
  type        = bool
  default     = false
}





