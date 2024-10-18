terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.7.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.6.0"
    }
  }
}
