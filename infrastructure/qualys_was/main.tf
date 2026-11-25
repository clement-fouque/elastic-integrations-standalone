module "integration" {
  source = "../modules/integration"

  integration_directory = "${path.module}/../../integrations/qualys_was"
  fleet_integrations    = var.fleet_integrations
}
