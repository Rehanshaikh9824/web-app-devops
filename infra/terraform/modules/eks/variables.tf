variable "cluster_name"              { type = string }
variable "kubernetes_version"         { type = string; default = "1.29" }
variable "cluster_role_arn"           { type = string }
variable "node_role_arn"              { type = string }
variable "cluster_security_group_id" { type = string }
variable "public_subnet_ids"          { type = list(string) }
variable "private_subnet_ids"         { type = list(string) }
variable "aws_region"                 { type = string }
variable "environment"                { type = string }
variable "instance_types"             { type = list(string); default = ["t3.medium"] }
variable "capacity_type"              { type = string; default = "ON_DEMAND" }
variable "desired_nodes"              { type = number; default = 2 }
variable "min_nodes"                  { type = number; default = 1 }
variable "max_nodes"                  { type = number; default = 4 }
variable "tags"                       { type = map(string); default = {} }
