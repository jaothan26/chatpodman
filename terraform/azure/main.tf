resource "azurerm_kubernetes_cluster" "chatpodman" {
  name                = "chatpodman-prod"
  location            = azurerm_resource_group.chatpodman.location
  resource_group_name = azurerm_resource_group.chatpodman.name
  dns_prefix          = "chatpodman-prod"
  kubernetes_version  = "1.28" # Pinned version
  sku_tier            = "Standard" # For SLA support

  default_node_pool {
    name                 = "default"
    node_count           = 2
    vm_size              = "Standard_D4s_v3"
    os_disk_size_gb      = 100
    type                 = "VirtualMachineScaleSets"
    enable_auto_scaling  = true
    min_count            = 2
    max_count            = 5
    vnet_subnet_id       = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    service_cidr   = "10.10.0.0/16"
    dns_service_ip = "10.10.0.10"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.monitoring.id
  }

  azure_policy_enabled = true

  tags = {
    Environment = "Production"
    Application = "ChatPodman"
  }
}
