variable "templates" {
  type     = any
  default  = {}
  nullable = false

  validation {
    condition = try(can(keys(var.templates)) && alltrue([
      for template in values(var.templates) :
      can(keys(template)) &&
      length(setsubtract(keys(template), ["template", "_meta", "version"])) == 0 &&
      contains(keys(template), "template") &&
      can(keys(template.template)) &&
      length(setsubtract(keys(template.template), ["settings", "mappings", "aliases", "data_stream_options"])) == 0 &&
      (contains(keys(template.template), "aliases") ? can(keys(template.template.aliases)) : true) &&
      (contains(keys(template.template), "aliases") ? alltrue([
        for alias in values(template.template.aliases) :
        can(keys(alias)) && length(setsubtract(keys(alias), ["filter", "index_routing", "is_hidden", "is_write_index", "routing", "search_routing"])) == 0
      ]) : true) &&
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
      ) : true)
    ]), false)
    error_message = "Component templates contain unsupported fields. Supported fields are template.settings, mappings, aliases, data_stream_options.failure_store, _meta, and version."
  }
}
