resource "google_compute_network" "vpc_network" {
  count                   = try(var.vpc_network_name, false)
  project                 = var.data_plane_project
  name                    = lower("${var.installation_name}-${var.country_code}-vpc")
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "The shared network for the identity graph"
}

data "google_compute_network" "vpc_network" {
  project = var.data_plane_project
  name    = try(var.vpc_network_name, google_compute_network.vpc_network[0].name)
}

module "network" {
  source                    = "./modules/network"
  installation_name         = var.installation_name
  country_code              = var.country_code
  project_id                = var.data_plane_project
  region                    = var.gcp_region
  network_name              = data.google_compute_network.vpc_network
  subnet_ip4_cidr           = var.dataproc_subnet_ip4_cidr
  subnet_user               = "serviceAccount:${google_service_account.tenant_data_access.email}"
  idapi_cidr_ip_addresses   = var.idapi_cidr_ip_addresses
  metastore_cidr_ip_address = var.metastore_cidr_ip_address
}
