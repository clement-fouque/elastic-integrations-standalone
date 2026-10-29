# Shared integration module

This module manages direct `*.json` files under an integration directory's
`pipelines/`, `component_templates/`, `index_templates/`, `ilm/`,
`data_streams/`, `transforms/`, `detection_rules/`, and `connectors/` folders. Each file's
basename without `.json` is the Elasticsearch resource ID, or the Kibana
`rule_id` for detection rules, or the connector reference key for connectors. The integration directory must exist;
missing or empty resource folders are valid. Nested files and non-JSON files
are ignored.
JSON is decoded in this parent module and passed to the corresponding type
module.

The supported JSON fields follow the body shapes of the Elasticsearch APIs and
are explicitly adapted to elasticstack provider `0.16.5`. Unknown fields on
resource bodies and structured subobjects are rejected. Opaque API payloads
such as mappings, ingest processors, transform queries, and pivot/latest
definitions are passed through as JSON.

Transform tuning fields belong inside the API's `settings` object, including
`align_checkpoints`, `dates_as_epoch_millis`, `deduce_mappings`,
`docs_per_second`, `max_page_search_size`, `num_failure_retries`, and
`unattended`. `source.index` accepts either a string or an array. ILM metadata
belongs inside `policy._meta`; all five supported phases and their
provider-supported actions are adapted explicitly. An empty action object
such as `readonly: {}` or `unfollow: {}` enables that action.

`detection_rules/*.json` bodies follow the Kibana Security detection rules
create API, without `rule_id`, and are adapted to the provider's
`elasticstack_kibana_security_detection_rule` resource. `query`, `esql` and
`new_terms` rules are accepted. `esql` rules must set `language` to `esql` and
set neither `index` nor `data_view_id`; `new_terms` rules must set
`new_terms_fields`, `history_window_start`, and `index` or `data_view_id`. Supported fields are `type`, `name`, `description`, `enabled`,
`version`, `severity`, `risk_score`, `index` or `data_view_id` (not both),
`language`, `query`, `interval`,
`from`, `to`, `timestamp_override`, `timestamp_override_fallback_disabled`,
`max_signals`, `author`, `license`, `tags`, `references`, `false_positives`,
`note`, `setup`, `investigation_fields.field_names`, `alert_suppression`,
`required_fields`, `related_integrations`, and `threat`. The API's
`alert_suppression.duration` object (`{"value": 72, "unit": "h"}`, units `s`,
`m`, or `h`) is converted to the provider's duration string.

Rules may also contain the API's `actions` array with `group`, `id`,
`action_type_id`, `params`, and `frequency` (`summary`, `notifyWhen`, and a
non-null `throttle` such as `rule`, `no_actions`, or `1h`). Unlike the API, an
action `id` is the filename stem of a connector in the same integration; the
module resolves it to the Kibana connector ID and creates connectors before
rules. Unknown connector stems are rejected.

`connectors/*.json` bodies follow the Kibana create connector API with only
`connector_type_id`, `name`, and an optional `config` object, adapted to
`elasticstack_kibana_action_connector`. Kibana generates the connector ID.
`secrets` are rejected in JSON. Supply them through the ephemeral, sensitive
`connector_secrets` map (JSON strings keyed by connector stem); they are sent via
the provider's write-only `secrets_wo` and never stored in state or saved plans.
Kibana cannot report secret drift, so change the matching
`connector_secret_versions` value to resend rotated secrets.

`data_streams/*.json` bodies must be `{}` because provider `0.16.5` exposes no
configurable data-stream create-body fields. The remote name still comes from
the filename.

`fleet_integrations` is a typed `map(object({ version = string }))`, keyed by
Fleet package name. It is independent of integration JSON files.

## Outputs

All resource maps are keyed by the relevant filename stem:

- `pipeline_names`: pipeline ID to remote name
- `data_stream_names`: data-stream ID to remote name
- `transform_names`: transform ID to remote name
- `transform_destination_indices`: transform ID to destination index
- `detection_rule_ids`: detection rule ID to Kibana `rule_id`
- `connector_ids`: connector stem to generated Kibana connector ID
- `fleet_integration_versions`: Fleet package name to installed version

## Notes

Provider connection settings, operation timeouts, and force-destruction
controls are Terraform concerns rather than Elasticsearch resource bodies and
are not accepted as JSON body fields. The provider itself validates its
attribute types and resource-specific constraints.
