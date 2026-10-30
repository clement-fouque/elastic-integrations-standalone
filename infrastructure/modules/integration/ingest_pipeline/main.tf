resource "elasticstack_elasticsearch_ingest_pipeline" "this" {
  for_each = var.pipelines

  name        = each.key
  description = try(each.value.description, null)
  metadata    = try(jsonencode(each.value._meta), null)
  processors  = [for processor in each.value.processors : jsonencode(processor)]
  on_failure  = try([for processor in each.value.on_failure : jsonencode(processor)], null)
}
