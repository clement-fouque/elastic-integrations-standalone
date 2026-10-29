output "names" {
  value = { for name in keys(var.policies) : name => name }
}
