locals {
  node_ip_address = libvirt_domain.this.network_interface[0].addresses[0]
}

resource "libvirt_volume" "this" {
  name           = var.name
  base_volume_id = var.base_volume_id
  size           = var.volume_size_gib * pow(2, 30) # GiB
}

resource "libvirt_domain" "this" {
  name      = var.name
  vcpu      = var.vcpu_count
  memory    = var.memory_mib
  autostart = true
  boot_device {
    dev = ["hd"]
  }
  disk {
    volume_id = libvirt_volume.this.id
  }
  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id     = var.network_id
    hostname       = var.name
    wait_for_lease = true
  }
  graphics {
    type        = "vnc"
    listen_type = "none"
  }
}

data "talos_machine_configuration" "this" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.control_plane_hostname}:6443"

  machine_type    = var.machine_type
  machine_secrets = var.talos_machine_secrets.machine_secrets

  talos_version      = "v${var.talos_version}"
  kubernetes_version = var.kubernetes_version

  config_patches = [
    yamlencode(
      {
        machine = {
          install = {
            disk = "/dev/vda"
          }

          time = {
            servers = [
              "/dev/ptp0"
            ]
          }
          network = {
            hostname = var.name
            interfaces = [
              {
                deviceSelector = {
                  busPath = "0*"
                }
                dhcp      = true
                addresses = [local.node_ip_address]
              }
            ]
          }
          certSANs = [
            "127.0.0.1"
          ]
        }
        cluster = {
          controlPlane = {
            endpoint = "https://${local.node_ip_address}:6443"
          }
        }
      }
    )
  ]

  depends_on = [libvirt_domain.this]
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = var.talos_machine_secrets["client_configuration"]
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = var.name
  endpoint                    = local.node_ip_address
}
