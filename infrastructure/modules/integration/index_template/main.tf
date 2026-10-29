resource "elasticstack_elasticsearch_index_template" "this" {
  for_each = var.templates

  name                               = each.key
  index_patterns                     = each.value.index_patterns
  priority                           = try(each.value.priority, null)
  composed_of                        = try(each.value.composed_of, null)
  ignore_missing_component_templates = try(each.value.ignore_missing_component_templates, null)
  metadata                           = try(jsonencode(each.value._meta), null)
  version                            = try(each.value.version, null)
  allow_auto_create                  = try(each.value.allow_auto_create, null)

  dynamic "template" {
    for_each = try(each.value.template, null) == null ? [] : [each.value.template]
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

      dynamic "lifecycle" {
        for_each = try(template.value.lifecycle, null) == null ? [] : [template.value.lifecycle]
        content {
          data_retention = try(lifecycle.value.data_retention, null)
        }
      }
    }
  }

  dynamic "data_stream" {
    for_each = try(each.value.data_stream, null) == null ? [] : [each.value.data_stream]
    content {
      hidden               = try(data_stream.value.hidden, null)
      allow_custom_routing = try(data_stream.value.allow_custom_routing, null)
    }
  }
}
