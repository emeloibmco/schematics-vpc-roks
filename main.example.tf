terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "~> 1.30.2"
    }
  }
}
##############################################################################
# Despliegue de recursos en el datacenter 
##############################################################################
provider "ibm" {
  alias  = "primary"
  region = var.region
  max_retries = 20
}
data "ibm_resource_group" "group" {
  provider = ibm.primary
  name = var.resource_group
}
##############################################################################
# Recuperar data de la SSH Key
##############################################################################
data "ibm_is_ssh_key" "sshkeypr" {
  provider = ibm.primary
  name = var.ssh_keyname
}
##############################################################################
# Recuperar data de la VPC 
##############################################################################
data "ibm_is_vpc" "pr_vpc" {
  provider = ibm.primary
  name = var.name_vpc
}
##############################################################################
# Recuperar data de la subnet
##############################################################################
data "ibm_is_subnet" "pr_subnet" {
  provider = ibm.primary
  name = var.name_subnet
}
resource "ibm_is_instance" "cce-vsi-pr" {
  provider = ibm.primary
  name    = "cce-vsipr-1"
  image   = var.image_vsi
  profile = "cx2-4x8"
  primary_network_interface {
    subnet = data.ibm_is_subnet.pr_subnet.id
  }
  vpc       = data.ibm_is_vpc.pr_vpc.id
  zone      = "${var.region-name}-${var.subnet_zone}"
  keys      = [data.ibm_is_ssh_key.sshkeypr.id]
  resource_group = data.ibm_resource_group.group.id
}



