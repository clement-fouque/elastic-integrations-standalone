resource "elasticstack_fleet_integration" "this" {
  for_each = var.fleet_integrations

  name         = each.key
  version      = each.value.version
  force        = true
  skip_destroy = true
}
