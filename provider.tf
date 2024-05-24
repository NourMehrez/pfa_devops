# Déclaration du fournisseur OpenStack
provider "openstack" {
  user_name   = "admin"
  tenant_name = "demo"
  password    = "secret"
  auth_url    = "http://192.168.56.108/identity"
  region      = "RegionOne"
}

terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}