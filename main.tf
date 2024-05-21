##############################################################################
# Terraform Providers
##############################################################################
terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">=1.19.0"
    }
  }
}
##############################################################################
# Provider
##############################################################################
provider ibm {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibm_region
  ibmcloud_timeout = 60
  generation       = 2
}
##############################################################################
# Resource Group
##############################################################################

data ibm_resource_group resource_group {
  name = var.resource_group
}
##############################################################################
# VPC Data
#############################################################################
data ibm_is_vpc vpc {
  name = var.vpc_name
}
#############################################################################
# Get Subnet Data
# > If the subnets cannot all be gotten by name, replace the `name`
#   field with the `identifier` field and get the subnets by ID instead
#   of by name.
#############################################################################
data ibm_is_subnet subnets {
  count = length(var.subnet_names)
  name  = var.subnet_names[count.index]
}

##############################################################################
# Create IKS on VPC Cluster
##############################################################################

resource ibm_container_vpc_cluster cluster {

  name              = "${var.unique_id}-roks-cluster"
  vpc_id            = data.ibm_is_vpc.vpc.id
  resource_group_id = data.ibm_resource_group.resource_group.id
  flavor            = var.machine_type
  worker_count      = var.workers_per_zone
  kube_version      = var.kube_version != "" ? var.kube_version : null
  tags              = var.tags
  wait_till         = var.wait_till
  entitlement       = var.entitlement

  dynamic zones {
    for_each = data.ibm_is_subnet.subnets
    content {
      subnet_id = zones.value.id
      name      = zones.value.zone
    }
  }
}
##############################################################################
# Worker Pool
##############################################################################

resource ibm_container_vpc_worker_pool pool {

    count              = length(var.worker_pools)
    vpc_id             = data.ibm_is_vpc.vpc.id
    resource_group_id  = data.ibm_resource_group.resource_group.id
    entitlement        = var.entitlement
    cluster            = ibm_container_vpc_cluster.cluster.id
    worker_pool_name   = var.worker_pools[count.index].pool_name
    flavor             = var.worker_pools[count.index].machine_type
    worker_count       = var.worker_pools[count.index].workers_per_zone

    dynamic zones {
        for_each = data.ibm_is_subnet.subnets
        content {
            subnet_id = zones.value.id
            name      = zones.value.zone
        }
    }


}


