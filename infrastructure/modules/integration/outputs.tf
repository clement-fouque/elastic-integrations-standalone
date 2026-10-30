output "pipeline_names" {
  description = "Ingest pipeline names keyed by the JSON filename stem."
  value       = { for name in keys(local.pipelines) : name => name }
}

output "data_stream_names" {
  description = "Data stream names keyed by the JSON filename stem."
  value       = { for name in keys(local.data_streams) : name => name }
}

output "transform_names" {
  description = "Transform names keyed by the JSON filename stem."
  value       = { for name in keys(local.transforms) : name => name }
}

output "transform_destination_indices" {
  description = "Transform destination indices keyed by the transform filename stem."
  value       = { for name, body in local.transforms : name => body.dest.index }
}

output "detection_rule_ids" {
  description = "Security detection rule IDs keyed by the JSON filename stem."
  value       = module.detection_rule.rule_ids
}

output "fleet_integration_versions" {
  description = "Installed Fleet integration versions keyed by package name."
  value       = module.fleet_integration.versions
}

output "connector_ids" {
  description = "Kibana connector IDs keyed by the JSON filename stem."
  value       = module.connector.connector_ids
}
