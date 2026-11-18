module "integration" {
  source = "../modules/integration"

  integration_directory = "${path.module}/../../integrations/projectdiscovery"
  fleet_integrations    = var.fleet_integrations

  connector_secrets = {
    "projectdiscovery-slack" = jsonencode({ webhookUrl = var.projectdiscovery_slack_webhook_url })
  }
  connector_secret_versions = {
    "projectdiscovery-slack" = var.projectdiscovery_slack_webhook_url_version
  }
}
