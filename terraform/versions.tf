terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/local/croc"
      version = ">= 4.4.0"
    }
    template = {
      source  = "registry.terraform.io/local/template"
      version = ">= 1.0.0"
    }
  }
}
