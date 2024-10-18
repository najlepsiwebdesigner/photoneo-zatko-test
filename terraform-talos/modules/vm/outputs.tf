output "applied" {
  value      = true
  depends_on = [talos_machine_configuration_apply.this]
}

output "node_ip_address" {
  value = local.node_ip_address
}

output "hostname" {
  value = var.name
}
