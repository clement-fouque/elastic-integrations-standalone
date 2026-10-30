resource "elasticstack_elasticsearch_data_stream" "this" {
  for_each = var.data_streams

  name = each.key

  lifecycle {
    prevent_destroy = true
  }
}
