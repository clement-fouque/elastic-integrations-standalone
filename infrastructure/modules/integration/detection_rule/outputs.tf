output "rule_ids" {
  value = { for name in keys(var.rules) : name => name }
}
