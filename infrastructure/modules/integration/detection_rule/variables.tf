variable "rules" {
  type     = any
  default  = {}
  nullable = false

  validation {
    condition = try(can(keys(var.rules)) && alltrue([
      for rule in values(var.rules) :
      can(keys(rule)) &&
      length(setsubtract(keys(rule), [
        "type", "name", "description", "enabled", "version", "severity", "risk_score",
        "index", "data_view_id", "language", "query", "interval", "from", "to", "timestamp_override",
        "timestamp_override_fallback_disabled", "max_signals", "author", "license", "tags",
        "references", "false_positives", "note", "setup", "investigation_fields",
        "alert_suppression", "required_fields", "related_integrations", "threat", "actions",
        "new_terms_fields", "history_window_start",
      ])) == 0 &&
      try(contains(["query", "esql", "new_terms"], rule.type), false) &&
      (rule.type == "esql" ? (
        try(rule.language == "esql", false) &&
        !contains(keys(rule), "index") &&
        !contains(keys(rule), "data_view_id")
      ) : true) &&
      (rule.type == "new_terms" ? (
        try(length(rule.new_terms_fields) > 0 && alltrue([for field in rule.new_terms_fields : can(tostring(field))]), false) &&
        try(tostring(rule.history_window_start) != "", false) &&
        (contains(keys(rule), "index") || contains(keys(rule), "data_view_id"))
        ) : (
        !contains(keys(rule), "new_terms_fields") &&
        !contains(keys(rule), "history_window_start")
      )) &&
      alltrue([for key in ["name", "description", "query"] : contains(keys(rule), key)]) &&
      !(contains(keys(rule), "index") && contains(keys(rule), "data_view_id")) &&
      (contains(keys(rule), "investigation_fields") ? (
        can(keys(rule.investigation_fields)) &&
        length(setsubtract(keys(rule.investigation_fields), ["field_names"])) == 0
      ) : true) &&
      (contains(keys(rule), "alert_suppression") ? (
        can(keys(rule.alert_suppression)) &&
        length(setsubtract(keys(rule.alert_suppression), ["group_by", "duration", "missing_fields_strategy"])) == 0 &&
        (contains(keys(rule.alert_suppression), "duration") ? (
          can(keys(rule.alert_suppression.duration)) &&
          length(setsubtract(keys(rule.alert_suppression.duration), ["value", "unit"])) == 0 &&
          contains(["s", "m", "h"], rule.alert_suppression.duration.unit)
        ) : true)
      ) : true) &&
      (contains(keys(rule), "required_fields") ? alltrue([
        for field in rule.required_fields :
        can(keys(field)) && length(setsubtract(keys(field), ["name", "type"])) == 0
      ]) : true) &&
      (contains(keys(rule), "related_integrations") ? alltrue([
        for integration in rule.related_integrations :
        can(keys(integration)) && length(setsubtract(keys(integration), ["package", "version", "integration"])) == 0
      ]) : true) &&
      (contains(keys(rule), "actions") ? alltrue([
        for action in rule.actions :
        can(keys(action)) &&
        length(setsubtract(keys(action), ["group", "id", "action_type_id", "params", "frequency"])) == 0 &&
        alltrue([for key in ["id", "action_type_id", "params"] : contains(keys(action), key)]) &&
        contains(keys(var.connector_ids), action.id) &&
        can(keys(action.params)) &&
        (contains(keys(action), "frequency") ? (
          can(keys(action.frequency)) &&
          length(setsubtract(keys(action.frequency), ["summary", "notifyWhen", "throttle"])) == 0 &&
          alltrue([for key in ["summary", "notifyWhen", "throttle"] : contains(keys(action.frequency), key)]) &&
          try(action.frequency.throttle != null && can(tostring(action.frequency.throttle)), false)
        ) : true)
      ]) : true) &&
      (contains(keys(rule), "threat") ? alltrue([
        for threat in rule.threat :
        can(keys(threat)) &&
        length(setsubtract(keys(threat), ["framework", "tactic", "technique"])) == 0 &&
        length(setsubtract(keys(threat.tactic), ["id", "name", "reference"])) == 0 &&
        alltrue([
          for technique in try(threat.technique, []) :
          length(setsubtract(keys(technique), ["id", "name", "reference", "subtechnique"])) == 0 &&
          alltrue([
            for subtechnique in try(technique.subtechnique, []) :
            length(setsubtract(keys(subtechnique), ["id", "name", "reference"])) == 0
          ])
        ])
      ]) : true)
    ]), false)
    error_message = "Detection rule JSON must be a query, esql, or new_terms rule with name, description, and query, must not set both index and data_view_id, esql rules must set language esql and set neither index nor data_view_id, new_terms rules must set non-empty new_terms_fields, history_window_start, and index or data_view_id (other types must set neither new-terms field), and must not contain unsupported fields or malformed alert_suppression, investigation_fields, required_fields, related_integrations, actions, or threat objects. Action ids must name a connector JSON filename stem, and action frequency needs summary, notifyWhen, and a non-null throttle."
  }
}

variable "connector_ids" {
  description = "Kibana connector IDs keyed by connector filename stem, referenced by rule action ids."
  type        = map(string)
  default     = {}
  nullable    = false
}
