resource "elasticstack_kibana_security_detection_rule" "this" {
  for_each = var.rules

  rule_id                              = each.key
  type                                 = each.value.type
  name                                 = each.value.name
  description                          = each.value.description
  enabled                              = try(each.value.enabled, null)
  version                              = try(each.value.version, null)
  severity                             = try(each.value.severity, null)
  risk_score                           = try(each.value.risk_score, null)
  index                                = try(tolist(each.value.index), null)
  data_view_id                         = try(each.value.data_view_id, null)
  language                             = try(each.value.language, null)
  query                                = each.value.query
  new_terms_fields                     = try(tolist(each.value.new_terms_fields), null)
  history_window_start                 = try(each.value.history_window_start, null)
  interval                             = try(each.value.interval, null)
  from                                 = try(each.value.from, null)
  to                                   = try(each.value.to, null)
  timestamp_override                   = try(each.value.timestamp_override, null)
  timestamp_override_fallback_disabled = try(each.value.timestamp_override_fallback_disabled, null)
  max_signals                          = try(each.value.max_signals, null)
  author                               = try(tolist(each.value.author), null)
  license                              = try(each.value.license, null)
  tags                                 = try(tolist(each.value.tags), null)
  references                           = try(tolist(each.value.references), null)
  false_positives                      = try(tolist(each.value.false_positives), null)
  note                                 = try(each.value.note, null)
  setup                                = try(each.value.setup, null)
  investigation_fields                 = try(tolist(each.value.investigation_fields.field_names), null)

  # The Kibana API expresses suppression duration as {value, unit}; the provider takes "<value><unit>".
  alert_suppression = try(each.value.alert_suppression, null) == null ? null : {
    group_by                = try(tolist(each.value.alert_suppression.group_by), null)
    duration                = try("${each.value.alert_suppression.duration.value}${each.value.alert_suppression.duration.unit}", null)
    missing_fields_strategy = try(each.value.alert_suppression.missing_fields_strategy, null)
  }

  required_fields = try(each.value.required_fields, null) == null ? null : [
    for field in each.value.required_fields : {
      name = field.name
      type = field.type
    }
  ]

  related_integrations = try(each.value.related_integrations, null) == null ? null : [
    for integration in each.value.related_integrations : {
      package     = integration.package
      version     = integration.version
      integration = try(integration.integration, null)
    }
  ]

  # Action IDs in rule JSON name a connector by its filename stem; resolve them to Kibana connector IDs.
  actions = try(each.value.actions, null) == null ? null : [
    for action in each.value.actions : {
      action_type_id = action.action_type_id
      id             = var.connector_ids[action.id]
      group          = try(action.group, null)
      params         = jsonencode(action.params)
      frequency = try(action.frequency, null) == null ? null : {
        notify_when = action.frequency.notifyWhen
        summary     = action.frequency.summary
        throttle    = action.frequency.throttle
      }
    }
  ]

  threat = try(each.value.threat, null) == null ? null : [
    for threat in each.value.threat : {
      framework = threat.framework
      tactic = {
        id        = threat.tactic.id
        name      = threat.tactic.name
        reference = threat.tactic.reference
      }
      technique = try(threat.technique, null) == null ? null : [
        for technique in threat.technique : {
          id        = technique.id
          name      = technique.name
          reference = technique.reference
          subtechnique = try(technique.subtechnique, null) == null ? null : [
            for subtechnique in technique.subtechnique : {
              id        = subtechnique.id
              name      = subtechnique.name
              reference = subtechnique.reference
            }
          ]
        }
      ]
    }
  ]
}
