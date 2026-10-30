terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.16.6"
    }
  }
}
