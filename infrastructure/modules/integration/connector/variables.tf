variable "connectors" {
  type     = any
  default  = {}
  nullable = false

  validation {
    condition = try(can(keys(var.connectors)) && alltrue([
      for connector in values(var.connectors) :
      can(keys(connector)) &&
      length(setsubtract(keys(connector), ["connector_type_id", "name", "config"])) == 0 &&
      can(tostring(connector.connector_type_id)) &&
      can(tostring(connector.name)) &&
      (contains(keys(connector), "config") ? can(keys(connector.config)) : true)
    ]), false)
    error_message = "Connector JSON must contain connector_type_id and name, an optional config object, and no other fields. Never put secrets in connector JSON."
  }
}

variable "secrets" {
  description = "JSON-encoded connector secrets keyed by connector filename stem."
  type        = map(string)
  default     = {}
  nullable    = false
  sensitive   = true
  ephemeral   = true
}

variable "secret_versions" {
  description = "Version strings keyed by connector filename stem. Change one to resend that connector's write-only secrets."
  type        = map(string)
  default     = {}
  nullable    = false
}
