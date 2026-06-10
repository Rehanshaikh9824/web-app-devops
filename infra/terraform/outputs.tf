output "resource_group_name" {
  value = module.resource_group.name
}

output "aks_cluster_name" {
  value = var.aks_name
}

output "acr_id" {
  value = module.acr.id
}

output "subnet_id" {
  value = module.network.subnet_id
}