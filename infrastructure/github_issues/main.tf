module "integration" {
  source = "../modules/integration"

  integration_directory = "${path.module}/../../integrations/github_issues"
  fleet_integrations    = var.fleet_integrations
}
