module "integration" {
  source = "../modules/integration"

  integration_directory = "${path.module}/../../integrations/github_security_advisories"
  fleet_integrations    = var.fleet_integrations

  connector_secrets = {
    "github-security-advisories-slack" = jsonencode({ webhookUrl = var.github_security_advisories_slack_webhook_url })
  }
  connector_secret_versions = {
    "github-security-advisories-slack" = var.github_security_advisories_slack_webhook_url_version
  }
}
