output "versions" {
  value = { for name, integration in var.fleet_integrations : name => integration.version }
}
