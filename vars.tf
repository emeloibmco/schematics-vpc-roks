variable "region-name" {
  default = "us-south"
  description = "name of the region"
}
variable "ssh_keyname" {
  description = "ssh key name of primary region"
}
variable "resource_group" {
  description = "resource group name"
}
variable "name_vpc" {
  description = "vpc name"
}
variable "name_subnet" {
  description = "subnet name"
}
variable "subnet_zone" {
  default = "1"
  description = "number that identify the zone"
}
variable "image_vsi" {
  description = "vsi image"
}
