resource "elasticstack_kibana_action_connector" "this" {
  for_each = var.connectors

  name              = each.value.name
  connector_type_id = each.value.connector_type_id
  config            = try(jsonencode(each.value.config), null)

  # Write-only: secrets reach Kibana but are never stored in state or saved plans.
  # Kibana cannot report secret drift, so rotation requires a new version.
  secrets_wo         = lookup(var.secrets, each.key, null)
  secrets_wo_version = lookup(var.secret_versions, each.key, null)
}
