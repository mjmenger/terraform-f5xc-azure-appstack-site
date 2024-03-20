############################ Volterra Azure Appstack Site ############################

resource "volterra_azure_vnet_site" "azure-site" {
  name           = format("%s-azureappstack-%s", var.project_prefix, var.instance_suffix)
  namespace      = "system"
  azure_region   = var.azure_region
  resource_group = "${var.resource_group}-appstack-site"
  // Minimum resource requirements can be found https://docs.cloud.f5.com/docs/how-to/site-management/create-azure-site
  machine_type   = var.k8s_node_instance_type # Modify machine type to match resource requirements (minimum 4x VCPU, 14GB RAM)
  ssh_key        = var.ssh_public_key

  #assisted                = false
  logs_streaming_disabled = true
  //One of the values on lines 15-16-17 must be set
  no_worker_nodes         = true 
  #nodes_per_az = "1" 
  #total_nodes = 6

  azure_cred {
    name      = var.volterra_cloud_cred_azure
    namespace = "system" //Cloud Credentials are created in the System Namespace only
  }

  voltstack_cluster {
  
    azure_certified_hw = "azure-byol-voltstack-combo"

    az_nodes {
      azure_az  = "1"
      disk_size = 80 // Modify disk size as needed
      local_subnet {
        subnet {
          subnet_name         = "internal_subnet"
          vnet_resource_group = true
        }
      }
    }

    az_nodes {
      azure_az  = "2"
      disk_size = 80 // Modify disk size as needed
      local_subnet {
        subnet {
          subnet_name         = "internal_subnet"
          vnet_resource_group = true
        }
      }
    }

    az_nodes {
      azure_az  = "3"
      disk_size = 80 // Modify disk size as needed
      local_subnet {
        subnet {
          subnet_name         = "internal_subnet"
          vnet_resource_group = true
        }
      }
    }

    no_network_policy        = true
    no_forward_proxy         = true
    no_outside_static_routes = true
   #no_k8s_cluster           = true
    no_global_network        = true
    #default_storage         = ""
    storage_class_list {
      storage_classes {
          default_storage_class = true
          storage_class_name = "etcd-storage"
      }
      storage_classes {
          default_storage_class = false
          storage_class_name = "hostpath"
      }
      storage_classes {
          default_storage_class = false
          storage_class_name = "standard"
      }
    }
    k8s_cluster {
      namespace = var.k8s_cluster_namespace // Value obtained from mk8s cluster creation module
      name      = var.k8s_cluster_name      // Value obtained from mk8s cluster creation module
    }
  }

  vnet {
    existing_vnet {
      resource_group = var.resource_group
      vnet_name      = var.hub_vnet_name
    }
  }

  lifecycle {
    ignore_changes = [labels]
  }

}

resource "volterra_cloud_site_labels" "labels" {
  name      = volterra_azure_vnet_site.azure-site.name
  site_type = "azure_vnet_site" 
  labels = {
    site-group = var.project_prefix
    appstack-site-group = var.project_prefix
  }
  ignore_on_delete = true
}

resource "volterra_tf_params_action" "azure-site" {
  site_name        = volterra_azure_vnet_site.azure-site.name
  site_kind        = "azure_vnet_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = false

  depends_on = [volterra_azure_vnet_site.azure-site]
}
