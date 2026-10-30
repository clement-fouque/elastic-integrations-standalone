variable "fleet_integrations" {
  description = "Published Fleet packages to install, configured in the integration's terraform.tfvars."
  type = map(object({
    version = string
  }))
  default  = {}
  nullable = false
}

variable "first_epss_slack_webhook_url" {
  description = "Slack incoming webhook URL for FIRST EPSS detection rule alerts. Supply via TF_VAR_first_epss_slack_webhook_url in the Git-ignored .env; never commit it."
  type        = string
  nullable    = false
  sensitive   = true
  ephemeral   = true

  validation {
    condition     = startswith(var.first_epss_slack_webhook_url, "https://hooks.slack.com/")
    error_message = "Set TF_VAR_first_epss_slack_webhook_url to a Slack incoming webhook URL (https://hooks.slack.com/...)."
  }
}

variable "first_epss_slack_webhook_url_version" {
  description = "Non-secret version label for the Slack webhook URL. Change it after rotating the URL so OpenTofu resends the write-only secret."
  type        = string
  default     = "1"
  nullable    = false
}
