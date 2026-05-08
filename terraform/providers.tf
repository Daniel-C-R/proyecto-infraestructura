terraform {
  required_version = ">= 1.6.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.2.0"
    }
  }
}

provider "openstack" {
  auth_url                      = var.auth_url
  application_credential_id     = var.application_credential_id
  application_credential_secret = var.application_credential_secret
  domain_name                   = var.domain_name
  tenant_name                   = var.tenant_name
  region                        = var.region
}
