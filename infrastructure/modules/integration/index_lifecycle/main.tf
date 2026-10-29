resource "elasticstack_elasticsearch_index_lifecycle" "this" {
  for_each = var.policies

  name     = each.key
  metadata = try(jsonencode(each.value.policy._meta), null)

  dynamic "hot" {
    for_each = try(each.value.policy.phases.hot, null) == null ? [] : [each.value.policy.phases.hot]
    content {
      min_age = try(hot.value.min_age, null)
      dynamic "rollover" {
        for_each = try(hot.value.actions.rollover, null) == null ? [] : [hot.value.actions.rollover]
        content {
          max_age                = try(rollover.value.max_age, null)
          max_docs               = try(rollover.value.max_docs, null)
          max_primary_shard_docs = try(rollover.value.max_primary_shard_docs, null)
          max_primary_shard_size = try(rollover.value.max_primary_shard_size, null)
          max_size               = try(rollover.value.max_size, null)
          min_age                = try(rollover.value.min_age, null)
          min_docs               = try(rollover.value.min_docs, null)
          min_primary_shard_docs = try(rollover.value.min_primary_shard_docs, null)
          min_primary_shard_size = try(rollover.value.min_primary_shard_size, null)
          min_size               = try(rollover.value.min_size, null)
        }
      }
      dynamic "set_priority" {
        for_each = try(hot.value.actions.set_priority, null) == null ? [] : [hot.value.actions.set_priority]
        content { priority = try(set_priority.value.priority, null) }
      }
      dynamic "downsample" {
        for_each = try(hot.value.actions.downsample, null) == null ? [] : [hot.value.actions.downsample]
        content {
          fixed_interval = try(downsample.value.fixed_interval, null)
          wait_timeout   = try(downsample.value.wait_timeout, null)
        }
      }
      dynamic "forcemerge" {
        for_each = try(hot.value.actions.forcemerge, null) == null ? [] : [hot.value.actions.forcemerge]
        content {
          index_codec      = try(forcemerge.value.index_codec, null)
          max_num_segments = try(forcemerge.value.max_num_segments, null)
        }
      }
      dynamic "readonly" {
        for_each = try(hot.value.actions.readonly, null) == null ? [] : [hot.value.actions.readonly]
        content { enabled = try(readonly.value.enabled, true) }
      }
      dynamic "searchable_snapshot" {
        for_each = try(hot.value.actions.searchable_snapshot, null) == null ? [] : [hot.value.actions.searchable_snapshot]
        content {
          force_merge_index    = try(searchable_snapshot.value.force_merge_index, null)
          force_merge_on_clone = try(searchable_snapshot.value.force_merge_on_clone, null)
          snapshot_repository  = try(searchable_snapshot.value.snapshot_repository, null)
        }
      }
      dynamic "shrink" {
        for_each = try(hot.value.actions.shrink, null) == null ? [] : [hot.value.actions.shrink]
        content {
          allow_write_after_shrink = try(shrink.value.allow_write_after_shrink, null)
          max_primary_shard_size   = try(shrink.value.max_primary_shard_size, null)
          number_of_shards         = try(shrink.value.number_of_shards, null)
        }
      }
      dynamic "unfollow" {
        for_each = try(hot.value.actions.unfollow, null) == null ? [] : [hot.value.actions.unfollow]
        content { enabled = try(unfollow.value.enabled, true) }
      }
    }
  }

  dynamic "warm" {
    for_each = try(each.value.policy.phases.warm, null) == null ? [] : [each.value.policy.phases.warm]
    content {
      min_age = try(warm.value.min_age, null)
      dynamic "allocate" {
        for_each = try(warm.value.actions.allocate, null) == null ? [] : [warm.value.actions.allocate]
        content {
          exclude               = try(jsonencode(allocate.value.exclude), null)
          include               = try(jsonencode(allocate.value.include), null)
          number_of_replicas    = try(allocate.value.number_of_replicas, null)
          require               = try(jsonencode(allocate.value.require), null)
          total_shards_per_node = try(allocate.value.total_shards_per_node, null)
        }
      }
      dynamic "downsample" {
        for_each = try(warm.value.actions.downsample, null) == null ? [] : [warm.value.actions.downsample]
        content {
          fixed_interval = try(downsample.value.fixed_interval, null)
          wait_timeout   = try(downsample.value.wait_timeout, null)
        }
      }
      dynamic "forcemerge" {
        for_each = try(warm.value.actions.forcemerge, null) == null ? [] : [warm.value.actions.forcemerge]
        content {
          index_codec      = try(forcemerge.value.index_codec, null)
          max_num_segments = try(forcemerge.value.max_num_segments, null)
        }
      }
      dynamic "migrate" {
        for_each = try(warm.value.actions.migrate, null) == null ? [] : [warm.value.actions.migrate]
        content { enabled = try(migrate.value.enabled, true) }
      }
      dynamic "readonly" {
        for_each = try(warm.value.actions.readonly, null) == null ? [] : [warm.value.actions.readonly]
        content { enabled = try(readonly.value.enabled, true) }
      }
      dynamic "set_priority" {
        for_each = try(warm.value.actions.set_priority, null) == null ? [] : [warm.value.actions.set_priority]
        content { priority = try(set_priority.value.priority, null) }
      }
      dynamic "shrink" {
        for_each = try(warm.value.actions.shrink, null) == null ? [] : [warm.value.actions.shrink]
        content {
          allow_write_after_shrink = try(shrink.value.allow_write_after_shrink, null)
          max_primary_shard_size   = try(shrink.value.max_primary_shard_size, null)
          number_of_shards         = try(shrink.value.number_of_shards, null)
        }
      }
      dynamic "unfollow" {
        for_each = try(warm.value.actions.unfollow, null) == null ? [] : [warm.value.actions.unfollow]
        content { enabled = try(unfollow.value.enabled, true) }
      }
    }
  }

  dynamic "cold" {
    for_each = try(each.value.policy.phases.cold, null) == null ? [] : [each.value.policy.phases.cold]
    content {
      min_age = try(cold.value.min_age, null)
      dynamic "allocate" {
        for_each = try(cold.value.actions.allocate, null) == null ? [] : [cold.value.actions.allocate]
        content {
          exclude               = try(jsonencode(allocate.value.exclude), null)
          include               = try(jsonencode(allocate.value.include), null)
          number_of_replicas    = try(allocate.value.number_of_replicas, null)
          require               = try(jsonencode(allocate.value.require), null)
          total_shards_per_node = try(allocate.value.total_shards_per_node, null)
        }
      }
      dynamic "downsample" {
        for_each = try(cold.value.actions.downsample, null) == null ? [] : [cold.value.actions.downsample]
        content {
          fixed_interval = try(downsample.value.fixed_interval, null)
          wait_timeout   = try(downsample.value.wait_timeout, null)
        }
      }
      dynamic "freeze" {
        for_each = try(cold.value.actions.freeze, null) == null ? [] : [cold.value.actions.freeze]
        content { enabled = try(freeze.value.enabled, true) }
      }
      dynamic "migrate" {
        for_each = try(cold.value.actions.migrate, null) == null ? [] : [cold.value.actions.migrate]
        content { enabled = try(migrate.value.enabled, true) }
      }
      dynamic "readonly" {
        for_each = try(cold.value.actions.readonly, null) == null ? [] : [cold.value.actions.readonly]
        content { enabled = try(readonly.value.enabled, true) }
      }
      dynamic "searchable_snapshot" {
        for_each = try(cold.value.actions.searchable_snapshot, null) == null ? [] : [cold.value.actions.searchable_snapshot]
        content {
          force_merge_index    = try(searchable_snapshot.value.force_merge_index, null)
          force_merge_on_clone = try(searchable_snapshot.value.force_merge_on_clone, null)
          snapshot_repository  = try(searchable_snapshot.value.snapshot_repository, null)
        }
      }
      dynamic "set_priority" {
        for_each = try(cold.value.actions.set_priority, null) == null ? [] : [cold.value.actions.set_priority]
        content { priority = try(set_priority.value.priority, null) }
      }
      dynamic "unfollow" {
        for_each = try(cold.value.actions.unfollow, null) == null ? [] : [cold.value.actions.unfollow]
        content { enabled = try(unfollow.value.enabled, true) }
      }
    }
  }

  dynamic "frozen" {
    for_each = try(each.value.policy.phases.frozen, null) == null ? [] : [each.value.policy.phases.frozen]
    content {
      min_age = try(frozen.value.min_age, null)
      dynamic "searchable_snapshot" {
        for_each = try(frozen.value.actions.searchable_snapshot, null) == null ? [] : [frozen.value.actions.searchable_snapshot]
        content {
          force_merge_index    = try(searchable_snapshot.value.force_merge_index, null)
          force_merge_on_clone = try(searchable_snapshot.value.force_merge_on_clone, null)
          snapshot_repository  = try(searchable_snapshot.value.snapshot_repository, null)
        }
      }
    }
  }

  dynamic "delete" {
    for_each = try(each.value.policy.phases.delete, null) == null ? [] : [each.value.policy.phases.delete]
    content {
      min_age = try(delete.value.min_age, null)
      dynamic "delete" {
        for_each = try(delete.value.actions.delete, null) == null ? [] : [delete.value.actions.delete]
        content {
          delete_searchable_snapshot = try(delete.value.delete_searchable_snapshot, null)
        }
      }
      dynamic "wait_for_snapshot" {
        for_each = try(delete.value.actions.wait_for_snapshot, null) == null ? [] : [delete.value.actions.wait_for_snapshot]
        content {
          policy = try(wait_for_snapshot.value.policy, null)
        }
      }
    }
  }
}
