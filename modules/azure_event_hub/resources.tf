terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      configuration_aliases = [
        azurerm.auth_session,
      ]
    }
  }
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_eventhub_namespace" "this" {
  provider = azurerm.auth_session

  name                = var.eventhub_namespace
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku                 = var.eventhub_sku
  capacity            = var.eventhub_capacity
}

# Event Hub (the topic)
resource "azurerm_eventhub" "this" {
  provider   = azurerm.auth_session
  depends_on = [azurerm_eventhub_namespace.this]

  name              = var.eventhub_topic
  namespace_id      = azurerm_eventhub_namespace.this.id
  partition_count   = var.eventhub_topic_partitions
  message_retention = var.eventhub_topic_message_retention
}

# Event Hub Consumer Group (for the function to read from)
resource "azurerm_eventhub_consumer_group" "this" {
  provider = azurerm.auth_session

  name                = "${var.eventhub_topic}-consumer-group"
  eventhub_name       = azurerm_eventhub.this.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = data.azurerm_resource_group.this.name
}
