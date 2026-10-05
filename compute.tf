# Azure Container Registry (ACR) to store microservices docker images
resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = true
}

# Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-${var.environment}-aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.prefix}-aks"

  default_node_pool {
    name           = "systempool"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    service_cidr       = "172.16.0.0/16"   # Non-overlapping range for Kubernetes internal services
    dns_service_ip     = "172.16.0.10"     # IP within the service_cidr for Kubernetes DNS
  }

  tags = {
    Environment = var.environment
    Project     = "Multi-Tenant SaaS"
  }
}