resource "elasticstack_elasticsearch_transform" "this" {
  for_each = var.transforms

  name                  = each.key
  description           = try(each.value.description, null)
  metadata              = try(jsonencode(each.value._meta), null)
  enabled               = try(each.value.enabled, true)
  defer_validation      = try(each.value.defer_validation, false)
  frequency             = try(each.value.frequency, null)
  latest                = try(jsonencode(each.value.latest), null)
  pivot                 = try(jsonencode(each.value.pivot), null)
  align_checkpoints     = try(each.value.settings.align_checkpoints, null)
  dates_as_epoch_millis = try(each.value.settings.dates_as_epoch_millis, null)
  deduce_mappings       = try(each.value.settings.deduce_mappings, null)
  docs_per_second       = try(each.value.settings.docs_per_second, null)
  max_page_search_size  = try(each.value.settings.max_page_search_size, null)
  num_failure_retries   = try(each.value.settings.num_failure_retries, null)
  unattended            = try(each.value.settings.unattended, null)

  dynamic "source" {
    for_each = [each.value.source]
    content {
      indices          = try(tolist(source.value.index), [source.value.index])
      query            = try(jsonencode(source.value.query), null)
      runtime_mappings = try(jsonencode(source.value.runtime_mappings), null)
    }
  }

  dynamic "destination" {
    for_each = [each.value.dest]
    content {
      index    = destination.value.index
      pipeline = try(destination.value.pipeline, null)

      dynamic "aliases" {
        for_each = try(destination.value.aliases, [])
        content {
          alias            = aliases.value.alias
          move_on_creation = try(aliases.value.move_on_creation, null)
        }
      }
    }
  }

  dynamic "sync" {
    for_each = try(each.value.sync.time, null) == null ? [] : [each.value.sync.time]
    content {
      dynamic "time" {
        for_each = [sync.value]
        content {
          field = try(time.value.field, null)
          delay = try(time.value.delay, null)
        }
      }
    }
  }

  dynamic "retention_policy" {
    for_each = try(each.value.retention_policy.time, null) == null ? [] : [each.value.retention_policy.time]
    content {
      dynamic "time" {
        for_each = [retention_policy.value]
        content {
          field   = try(time.value.field, null)
          max_age = try(time.value.max_age, null)
        }
      }
    }
  }
}
