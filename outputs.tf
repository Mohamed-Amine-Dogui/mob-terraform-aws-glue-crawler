# output.tf

output "crawler_arn" {
  value       = var.enable ? aws_glue_crawler.this[0].arn : ""
  description = "ARN of the Glue crawler"
}

output "crawler_iam_role_arn" {
  value       = var.enable ? aws_iam_role.glue_crawler_role[0].arn : ""
  description = "ARN of the IAM Role assumed by Glue crawler"
}


output "crawler_iam_role_name" {
  value       = var.enable ? aws_iam_role.glue_crawler_role[0].name : ""
  description = "Name of the IAM Role assumed by Glue crawler"
}

output "crawler_name" {
  value       = var.enable ? aws_glue_crawler.this[0].name : ""
  description = "Name of the Glue crawler"
}



output "enabled" {
  value = var.enable
}
