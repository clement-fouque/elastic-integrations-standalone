resource "elasticstack_elasticsearch_component_template" "this" {
  for_each = var.templates

  name     = each.key
  metadata = try(jsonencode(each.value._meta), null)
  version  = try(each.value.version, null)

  dynamic "template" {
    for_each = [each.value.template]
    content {
      mappings = try(jsonencode(template.value.mappings), null)
      settings = try(jsonencode(template.value.settings), null)

      dynamic "alias" {
        for_each = try(template.value.aliases, {})
        content {
          name           = alias.key
          filter         = try(jsonencode(alias.value.filter), null)
          index_routing  = try(alias.value.index_routing, null)
          is_hidden      = try(alias.value.is_hidden, null)
          is_write_index = try(alias.value.is_write_index, null)
          routing        = try(alias.value.routing, null)
          search_routing = try(alias.value.search_routing, null)
        }
      }

      dynamic "data_stream_options" {
        for_each = try(template.value.data_stream_options, null) == null ? [] : [template.value.data_stream_options]
        content {
          dynamic "failure_store" {
            for_each = try(data_stream_options.value.failure_store, null) == null ? [] : [data_stream_options.value.failure_store]
            content {
              enabled = try(failure_store.value.enabled, null)
              dynamic "lifecycle" {
                for_each = try(failure_store.value.lifecycle, null) == null ? [] : [failure_store.value.lifecycle]
                content {
                  data_retention = try(lifecycle.value.data_retention, null)
                }
              }
            }
          }
        }
      }
    }
  }
}
