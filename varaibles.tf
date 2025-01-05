variable "pve_host" {
  type = string
}

variable "pve_node" {
  type = string
}

variable "pve_password" {
  type      = string
  sensitive = true
}

variable "pve_user" {
  type = string
}

variable "opnsense_key" {
  type      = string
  sensitive = true
}

variable "opnsense_secret" {
  type      = string
  sensitive = true
}

