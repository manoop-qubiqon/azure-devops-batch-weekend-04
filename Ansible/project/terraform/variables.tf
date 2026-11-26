variable "resource_group_name" {
  description = "Resource group to hold all demo resources"
  type        = string
  default     = "ansible-demo-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "VM size (B-series is cheap for demos)"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "SSH admin user created on each VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
