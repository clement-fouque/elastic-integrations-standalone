output "names" {
  value = { for name in keys(var.transforms) : name => name }
}

output "destination_indices" {
  value = { for name, transform in var.transforms : name => transform.dest.index }
}
