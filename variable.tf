variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed."
  default     = "malaysiawest"
}

variable "prefix" {
  type        = string
  description = "The naming prefix to ensure global uniqueness for resources."
  default     = "azsaas"
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, staging, prod)."
  default     = "dev"
}