variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "kiosk"
}

variable "sql_admin_user" {
  description = "SQL admin username"
  type        = string
}

variable "sql_admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}