output "names" {
  value = { for name in keys(var.data_streams) : name => name }
}
