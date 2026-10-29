locals {
  pipelines = {
    for file in fileset(var.integration_directory, "pipelines/*.json") :
    trimsuffix(basename(file), ".json") => try(jsondecode(file("${var.integration_directory}/${file}")), {})
  }
  component_templates = {
    for file in fileset(var.integration_directory, "component_templates/*.json") :
    trimsuffix(basename(file), ".json") => try(jsondecode(file("${var.integration_directory}/${file}")), {})
  }
  index_templates = {
    for file in fileset(var.integration_directory, "index_templates/*.json") :
    trimsuffix(basename(file), ".json") => try(jsondecode(file("${var.integration_directory}/${file}")), {})
  }
  index_lifecycles = {
    for file in fileset(var.integration_directory, "ilm/*.json") :
    trimsuffix(basename(file), ".json") => try(jsondecode(file("${var.integration_directory}/${file}")), {})
  }
  data_streams = {
    for file in fileset(var.integration_directory, "data_streams/*.json") :
    trimsuffix(basename(file), ".json") => try(jsondecode(file("${var.integration_directory}/${file}")), {})
  }
  transforms = {
    for file in fileset(var.integration_directory, "transforms/*.json") :
    trimsuffix(basename(file), ".json") => try(jsondecode(file("${var.integration_directory}/${file}")), {})
  }
  detection_rules = {
    for file in fileset(var.integration_directory, "detection_rules/*.json") :
    trimsuffix(basename(file), ".json") => try(jsondecode(file("${var.integration_directory}/${file}")), {})
  }
  connectors = {
    for file in fileset(var.integration_directory, "connectors/*.json") :
    trimsuffix(basename(file), ".json") => try(jsondecode(file("${var.integration_directory}/${file}")), {})
  }
}

module "fleet_integration" {
  source = "./fleet_integration"

  fleet_integrations = var.fleet_integrations
}

module "ingest_pipeline" {
  source = "./ingest_pipeline"

  pipelines = local.pipelines

  depends_on = [module.fleet_integration]
}

module "index_lifecycle" {
  source = "./index_lifecycle"

  policies = local.index_lifecycles

  depends_on = [module.fleet_integration]
}

module "component_template" {
  source = "./component_template"

  templates = local.component_templates

  depends_on = [
    module.index_lifecycle,
    module.ingest_pipeline,
  ]
}

module "index_template" {
  source = "./index_template"

  templates = local.index_templates

  depends_on = [
    module.component_template,
    module.ingest_pipeline,
  ]
}

module "data_stream" {
  source = "./data_stream"

  data_streams = local.data_streams

  depends_on = [module.index_template]
}

module "transform" {
  source = "./transform"

  transforms = local.transforms

  depends_on = [
    module.data_stream,
    module.index_template,
  ]
}

module "connector" {
  source = "./connector"

  connectors      = local.connectors
  secrets         = var.connector_secrets
  secret_versions = var.connector_secret_versions
}

module "detection_rule" {
  source = "./detection_rule"

  rules         = local.detection_rules
  connector_ids = module.connector.connector_ids

  depends_on = [
    module.connector,
    module.fleet_integration,
  ]
}
