# Create a Resource Group to hold all our multi-tenant infrastructure
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "Multi-Tenant SaaS"
  }
}