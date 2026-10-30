module "integration" {
  source = "../modules/integration"

  integration_directory = "${path.module}/../../integrations/first_epss"
  fleet_integrations    = var.fleet_integrations

  connector_secrets = {
    "first-epss-slack" = jsonencode({ webhookUrl = var.first_epss_slack_webhook_url })
  }
  connector_secret_versions = {
    "first-epss-slack" = var.first_epss_slack_webhook_url_version
  }
}
