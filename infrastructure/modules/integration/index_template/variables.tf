variable "templates" {
  type     = any
  default  = {}
  nullable = false

  validation {
    condition = try(can(keys(var.templates)) && alltrue([
      for template in values(var.templates) :
      can(keys(template)) &&
      length(setsubtract(keys(template), ["index_patterns", "template", "priority", "composed_of", "ignore_missing_component_templates", "data_stream", "_meta", "version", "allow_auto_create"])) == 0 &&
      contains(keys(template), "index_patterns") &&
      can(concat(template.index_patterns, [])) &&
      (contains(keys(template), "template") ? (
        can(keys(template.template)) &&
        length(setsubtract(keys(template.template), ["settings", "mappings", "aliases", "data_stream_options", "lifecycle"])) == 0 &&
        (contains(keys(template.template), "aliases") ? (
          can(keys(template.template.aliases)) &&
          alltrue([for alias in values(template.template.aliases) : can(keys(alias)) && length(setsubtract(keys(alias), ["filter", "index_routing", "is_hidden", "is_write_index", "routing", "search_routing"])) == 0])
        ) : true) &&
        (contains(keys(template.template), "data_stream_options") ? (
          can(keys(template.template.data_stream_options)) &&
          length(setsubtract(keys(template.template.data_stream_options), ["failure_store"])) == 0 &&
          (contains(keys(template.template.data_stream_options), "failure_store") ? (
            can(keys(template.template.data_stream_options.failure_store)) &&
            length(setsubtract(keys(template.template.data_stream_options.failure_store), ["enabled", "lifecycle"])) == 0 &&
            (contains(keys(template.template.data_stream_options.failure_store), "lifecycle") ? (
              can(keys(template.template.data_stream_options.failure_store.lifecycle)) &&
              length(setsubtract(keys(template.template.data_stream_options.failure_store.lifecycle), ["data_retention"])) == 0
            ) : true)
          ) : true)
        ) : true) &&
        (contains(keys(template.template), "lifecycle") ? (
          can(keys(template.template.lifecycle)) &&
          length(setsubtract(keys(template.template.lifecycle), ["data_retention"])) == 0
        ) : true)
      ) : true) &&
      (contains(keys(template), "data_stream") ? (
        can(keys(template.data_stream)) &&
        length(setsubtract(keys(template.data_stream), ["hidden", "allow_custom_routing"])) == 0
      ) : true)
    ]), false)
    error_message = "Index templates contain unsupported fields or malformed index_patterns/template/data_stream properties."
  }
}
