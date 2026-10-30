variable "fleet_integrations" {
  description = "Fleet integrations keyed by name and pinned to a package version."
  type = map(object({
    version = string
  }))
  default  = {}
  nullable = false
}
