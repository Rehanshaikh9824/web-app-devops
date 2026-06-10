module "resource_group" {
  source = "./modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "network" {
  source = "./modules/network"

  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  tags                = var.tags
}

module "acr" {
  source = "./modules/acr"

  acr_name            = var.acr_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  tags                = var.tags
}

module "monitoring" {
  source = "./modules/monitoring"

  workspace_name      = var.log_analytics_workspace_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

module "aks" {
  source = "./modules/aks"

  aks_name            = var.aks_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  dns_prefix          = var.dns_prefix
  node_count          = var.node_count
  vm_size             = var.vm_size
  subnet_id           = module.network.subnet_id
  acr_id              = module.acr.id
  tags                = var.tags
}