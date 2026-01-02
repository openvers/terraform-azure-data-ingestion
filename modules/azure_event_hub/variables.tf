## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Event Hub namespace will be created."
}

variable "eventhub_namespace" {
  type        = string
  description = "The name of the Event Hub namespace."
}

variable "eventhub_topic" {
  type        = string
  description = "The name of the Event Hub topic."
}

# ## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "eventhub_sku" {
  type        = string
  description = "The SKU of the Event Hub namespace."
  default     = "Standard"
}

variable "eventhub_capacity" {
  type        = number
  description = "The capacity of the Event Hub namespace."
  default     = 1
}

variable "eventhub_topic_partitions" {
  type        = number
  description = "The number of partitions for the Event Hub topic."
  default     = 4
}

variable "eventhub_topic_message_retention" {
  type        = number
  description = "The message retention period for the Event Hub topic."
  default     = 1
}
