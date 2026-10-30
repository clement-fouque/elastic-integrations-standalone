output "names" {
  value = { for name in keys(var.pipelines) : name => name }
}
