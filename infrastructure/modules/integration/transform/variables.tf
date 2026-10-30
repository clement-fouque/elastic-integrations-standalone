variable "transforms" {
  type     = any
  default  = {}
  nullable = false

  validation {
    condition = try(can(keys(var.transforms)) && alltrue([
      for transform in values(var.transforms) :
      can(keys(transform)) &&
      length(setsubtract(keys(transform), [
        "description", "source", "dest", "latest", "pivot", "frequency",
        "settings", "_meta", "sync", "retention_policy", "enabled", "defer_validation",
      ])) == 0 &&
      (contains(keys(transform), "enabled") ? can(tobool(transform.enabled)) : true) &&
      (contains(keys(transform), "defer_validation") ? can(tobool(transform.defer_validation)) : true) &&
      contains(keys(transform), "source") &&
      can(keys(transform.source)) &&
      length(setsubtract(keys(transform.source), ["index", "query", "runtime_mappings"])) == 0 &&
      contains(keys(transform.source), "index") &&
      (can(concat(transform.source.index, [])) || startswith(jsonencode(transform.source.index), "\"")) &&
      contains(keys(transform), "dest") &&
      can(keys(transform.dest)) &&
      length(setsubtract(keys(transform.dest), ["index", "pipeline", "aliases"])) == 0 &&
      contains(keys(transform.dest), "index") &&
      (contains(keys(transform.dest), "aliases") ? (
        can(concat(transform.dest.aliases, [])) &&
        alltrue([for alias in transform.dest.aliases : can(keys(alias)) && length(setsubtract(keys(alias), ["alias", "move_on_creation"])) == 0 && contains(keys(alias), "alias")])
      ) : true) &&
      (contains(keys(transform), "sync") ? (
        can(keys(transform.sync)) &&
        length(setsubtract(keys(transform.sync), ["time"])) == 0 &&
        (contains(keys(transform.sync), "time") ? (
          can(keys(transform.sync.time)) &&
          length(setsubtract(keys(transform.sync.time), ["field", "delay"])) == 0
        ) : true)
      ) : true) &&
      (contains(keys(transform), "retention_policy") ? (
        can(keys(transform.retention_policy)) &&
        length(setsubtract(keys(transform.retention_policy), ["time"])) == 0 &&
        (contains(keys(transform.retention_policy), "time") ? (
          can(keys(transform.retention_policy.time)) &&
          length(setsubtract(keys(transform.retention_policy.time), ["field", "max_age"])) == 0
        ) : true)
      ) : true) &&
      (contains(keys(transform), "settings") ? (
        can(keys(transform.settings)) &&
        length(setsubtract(keys(transform.settings), [
          "align_checkpoints", "dates_as_epoch_millis", "deduce_mappings",
          "docs_per_second", "max_page_search_size", "num_failure_retries", "unattended",
        ])) == 0
      ) : true)
    ]), false)
    error_message = "Transform JSON contains unsupported fields or malformed source, destination, sync, retention_policy, or settings objects."
  }
}
