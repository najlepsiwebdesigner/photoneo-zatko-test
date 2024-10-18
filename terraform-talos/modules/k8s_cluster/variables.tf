variable "cluster_name" {
  type     = string
  nullable = false
}

variable "subnet_cidr" {
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

variable "control_plane_count" {
  type     = number
  nullable = false
}

variable "control_plane_vcpu_count" {
  type     = number
  nullable = false
}

variable "control_plane_memory_gib" {
  type     = number
  nullable = false
}

variable "control_plane_volume_size_gib" {
  type     = number
  nullable = false
}

variable "worker_count" {
  type     = number
  nullable = false
}

variable "worker_vcpu_count" {
  type     = number
  nullable = false
}

variable "worker_memory_gib" {
  type     = number
  nullable = false
}

variable "worker_volume_size_gib" {
  type     = number
  nullable = false
}
