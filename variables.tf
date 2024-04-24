variable "project_prefix" {
    type = string
}
variable "azure_region" {
    type = string
}
variable "resource_group" {
    type = string
}
variable "hub_vnet_name" {
    type = string
}
variable "volterra_cloud_cred_azure" {
    type = string
}
variable "ssh_public_key" {
    type = string
}
variable instance_suffix {
    type = string
}
variable k8s_cluster_name { 
    type = string
}
variable k8s_cluster_namespace {
    type = string
}
variable k8s_node_instance_type {
    type    = string
    default = "Standard_D8_v3"
}
variable disk_size {
    type    = number
    default = 80
}
