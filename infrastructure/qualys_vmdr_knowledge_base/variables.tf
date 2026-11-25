variable "fleet_integrations" {
  description = "Published Fleet packages to install, configured in the integration's terraform.tfvars."
  type = map(object({
    version = string
  }))
  default  = {}
  nullable = false
}
