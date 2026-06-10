variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnet_prefixes" {
  type = list(string)
}

variable "acr_name" {
  type = string
}

variable "acr_sku" {
  type = string
}

variable "acr_admin_enabled" {
  type = bool
}

variable "log_analytics_workspace_name" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "node_count" {
  type = number
}

variable "vm_size" {
  type = string
}