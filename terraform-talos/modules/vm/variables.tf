variable "name" {
  type     = string
  nullable = false
}

variable "cluster_name" {
  type     = string
  nullable = false
}

variable "talos_machine_secrets" {
  type     = any
  nullable = false
}

variable "machine_type" {
  type     = string
  nullable = false
}

variable "talos_version" {
  type     = string
  nullable = false
}

variable "kubernetes_version" {
  type     = string
  nullable = false
}

variable "base_volume_id" {
  type     = string
  nullable = false
}

variable "volume_size_gib" {
  type     = string
  nullable = false
}

variable "vcpu_count" {
  type     = string
  nullable = false
}

variable "memory_mib" {
  type     = string
  nullable = false
}

variable "network_id" {
  type     = string
  nullable = false
}

variable "control_plane_hostname" {
  type     = string
  nullable = false
}
