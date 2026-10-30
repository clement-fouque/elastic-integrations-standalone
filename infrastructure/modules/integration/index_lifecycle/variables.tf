variable "policies" {
  type     = any
  default  = {}
  nullable = false

  validation {
    condition = try(can(keys(var.policies)) && alltrue([
      for policy in values(var.policies) :
      can(keys(policy)) &&
      length(setsubtract(keys(policy), ["policy"])) == 0 &&
      contains(keys(policy), "policy") &&
      can(keys(policy.policy)) &&
      length(setsubtract(keys(policy.policy), ["phases", "_meta"])) == 0 &&
      contains(keys(policy.policy), "phases") &&
      can(keys(policy.policy.phases)) &&
      length(setsubtract(keys(policy.policy.phases), ["hot", "warm", "cold", "frozen", "delete"])) == 0 &&
      alltrue([
        for phase_name, phase in policy.policy.phases :
        can(keys(phase)) &&
        length(setsubtract(keys(phase), ["min_age", "actions"])) == 0 &&
        can(keys(try(phase.actions, {}))) &&
        alltrue([
          for action_name, action in try(phase.actions, {}) :
          can(keys(action)) &&
          contains(lookup({
            hot    = ["rollover", "set_priority", "downsample", "forcemerge", "readonly", "searchable_snapshot", "shrink", "unfollow"]
            warm   = ["allocate", "downsample", "forcemerge", "migrate", "readonly", "set_priority", "shrink", "unfollow"]
            cold   = ["allocate", "downsample", "freeze", "migrate", "readonly", "searchable_snapshot", "set_priority", "unfollow"]
            frozen = ["searchable_snapshot"]
            delete = ["delete", "wait_for_snapshot"]
          }, phase_name, []), action_name) &&
          length(setsubtract(keys(action), lookup({
            allocate            = ["exclude", "include", "number_of_replicas", "require", "total_shards_per_node"]
            downsample          = ["fixed_interval", "wait_timeout"]
            freeze              = ["enabled"]
            migrate             = ["enabled"]
            readonly            = ["enabled"]
            searchable_snapshot = ["force_merge_index", "force_merge_on_clone", "snapshot_repository"]
            set_priority        = ["priority"]
            unfollow            = ["enabled"]
            rollover            = ["max_age", "max_docs", "max_primary_shard_docs", "max_primary_shard_size", "max_size", "min_age", "min_docs", "min_primary_shard_docs", "min_primary_shard_size", "min_size"]
            forcemerge          = ["index_codec", "max_num_segments"]
            shrink              = ["allow_write_after_shrink", "max_primary_shard_size", "number_of_shards"]
            delete              = ["delete_searchable_snapshot"]
            wait_for_snapshot   = ["policy"]
          }, action_name, []))) == 0
        ])
      ])
    ]), false)
    error_message = "ILM policies contain unsupported policy, phase, action, or nested action fields for elasticstack 0.16.5."
  }
}
