output "connector_ids" {
  description = "Kibana connector IDs keyed by the JSON filename stem."
  value       = { for name, connector in elasticstack_kibana_action_connector.this : name => connector.connector_id }
}
