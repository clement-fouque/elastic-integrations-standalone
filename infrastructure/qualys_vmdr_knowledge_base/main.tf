module "integration" {
  source = "../modules/integration"

  integration_directory = "${path.module}/../../integrations/qualys_vmdr_knowledge_base"
  fleet_integrations    = var.fleet_integrations
}
