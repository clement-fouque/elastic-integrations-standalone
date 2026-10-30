variable "integration_directory" {
  description = "Path to an integration directory containing optional pipelines, component_templates, index_templates, ilm, data_streams, transforms, detection_rules, and connectors directories."
  type        = string
  nullable    = false

  validation {
    # fileexists errors on directories but returns false on nonexistent paths.
    condition     = !can(fileexists("${var.integration_directory}/."))
    error_message = "integration_directory must be an existing directory."
  }

  validation {
    condition = alltrue(flatten([
      for directory in ["pipelines", "component_templates", "index_templates", "ilm", "data_streams", "transforms", "detection_rules", "connectors"] : [
        for filename in fileset(var.integration_directory, "${directory}/*.json") :
        can(jsondecode(file("${var.integration_directory}/${filename}")))
      ]
    ]))
    error_message = "Every discovered integration asset must contain valid JSON."
  }
}

variable "fleet_integrations" {
  description = "Fleet integrations to install, keyed by integration name."
  type = map(object({
    version = string
  }))
  default  = {}
  nullable = false
}

variable "connector_secrets" {
  description = "JSON-encoded Kibana connector secrets keyed by connector filename stem. Ephemeral: never stored in state or saved plans."
  type        = map(string)
  default     = {}
  nullable    = false
  sensitive   = true
  ephemeral   = true
}

variable "connector_secret_versions" {
  description = "Non-secret version strings keyed by connector filename stem. Change a value to resend that connector's write-only secrets."
  type        = map(string)
  default     = {}
  nullable    = false
}
