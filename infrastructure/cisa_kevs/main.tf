module "integration" {
  source = "../modules/integration"

  integration_directory = "${path.module}/../../integrations/cisa_kevs"
  fleet_integrations    = var.fleet_integrations

  connector_secrets = {
    "cisa-kevs-slack" = jsonencode({ webhookUrl = var.cisa_kevs_slack_webhook_url })
  }
  connector_secret_versions = {
    "cisa-kevs-slack" = var.cisa_kevs_slack_webhook_url_version
  }
}
