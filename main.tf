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
  region           = var.ibm_region
  ibmcloud_api_key = var.ibmcloud_api_key
  max_retries = 20
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
# COS Instance
##############################################################################

resource ibm_resource_instance cos {
  name              = "${var.unique_id}-cos"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = data.ibm_resource_group.resource_group.id != "" ? data.ibm_resource_group.resource_group.id : null

  parameters = {
    service-endpoints = "private"
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }

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
  cos_instance_crn  = ibm_resource_instance.cos.id

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


