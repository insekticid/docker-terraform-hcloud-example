variable "hcloud_token" {}

variable "ssh_key_name" {
  default = "admin@example.com"
}

variable "ssh_private_key" {
  description = "Private Key to access the machines"
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_public_key" {
  description = "Public Key to authorized the access for the machines"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "docker_version" {
  default = "17"
}

variable "rancher_password" {
  default = "admin"
}

variable "rancher_version" {
  default = "v2.0.2"
}

variable "acme_domain" {
  default = "example.com"
}

variable "rancher_cluster_name" {
  default = "playground"
}