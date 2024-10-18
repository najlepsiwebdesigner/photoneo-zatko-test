locals {
  domain = "${var.cluster_name}.local"

  # DHCP cannot be disabled anyway :-)
  # https://github.com/dmacvicar/terraform-provider-libvirt/issues/998
  dhcp_enabled = true

  control_plane_ip_address = module.control_plane[0].node_ip_address
  control_plane_hostname   = module.control_plane[0].hostname
}

resource "libvirt_network" "this" {
  name      = var.cluster_name
  domain    = local.domain
  mode      = "nat"
  addresses = [var.subnet_cidr]
  autostart = true
  dhcp {
    enabled = local.dhcp_enabled
  }
  dns {
    enabled    = true
    local_only = false
  }
}

resource "libvirt_pool" "this" {
  name = var.cluster_name
  type = "dir"
  path = "/tmp/libvirt/pool/${var.cluster_name}"
}

resource "libvirt_volume" "talos" {
  name   = "talos_qcow2"
  pool   = var.cluster_name
  source = "files/talos-metal-amd64_v1.8.1.qcow2"
  format = "qcow2"
}

resource "talos_machine_secrets" "this" {
  talos_version = "v${var.talos_version}"
}

module "control_plane" {
  source = "../vm"
  count  = var.control_plane_count

  name         = "control-plane-${count.index + 1}"
  machine_type = "controlplane"

  cluster_name          = var.cluster_name
  talos_machine_secrets = talos_machine_secrets.this

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  base_volume_id  = libvirt_volume.talos.id
  volume_size_gib = var.control_plane_volume_size_gib

  vcpu_count = var.control_plane_vcpu_count
  memory_mib = var.control_plane_memory_gib

  network_id             = libvirt_network.this.id
  control_plane_hostname = local.control_plane_hostname
}

module "worker" {
  source = "../vm"
  count  = var.worker_count

  name         = "worker-${count.index + 1}"
  machine_type = "worker"

  cluster_name          = var.cluster_name
  talos_machine_secrets = talos_machine_secrets.this

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  base_volume_id  = libvirt_volume.talos.id
  volume_size_gib = var.worker_volume_size_gib

  vcpu_count = var.worker_vcpu_count
  memory_mib = var.worker_memory_gib

  network_id             = libvirt_network.this.id
  control_plane_hostname = local.control_plane_hostname
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints = [
    for node in module.control_plane :
    node.node_ip_address
  ]
  nodes = concat(
    [for node in module.control_plane : node.hostname],
    [for node in module.worker : node.hostname]
  )
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = module.control_plane[0].hostname
  endpoint             = module.control_plane[0].node_ip_address

  depends_on = [module.control_plane[0].applied]
}

data "talos_cluster_health" "this" {
  client_configuration = data.talos_client_configuration.this.client_configuration
  control_plane_nodes = [
    for module in module.control_plane : module.hostname
  ]
  worker_nodes = [
    for module in module.control_plane : module.hostname
  ]
  endpoints = data.talos_client_configuration.this.endpoints
}

data "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.control_plane_hostname

  depends_on = [
    talos_machine_bootstrap.this,
    data.talos_cluster_health.this
  ]
}
