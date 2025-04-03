resource "azurerm_kubernetes_cluster" "chatpodman" {
name = "chatpodman-prod"
location = azurerm_resource_group.chatpodman.location
resource_group_name = azurerm_resource_group.chatpodman.name
dns_prefix = "chatpodman"
default_node_pool {
name = "default"
node_count = 2
vm_size = "Standard_D4s_v3"
}
}
