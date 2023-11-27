resource "google_compute_network" "vpc_network" {
  project                 = var.data_plane_project
  name                    = lower("${var.installation_name}-${var.country_code}-vpc")
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "The shared network for the identity graph"
}

resource "google_compute_subnetwork" "dataproc_subnet" {
  project                  = var.data_plane_project
  region                   = var.gcp_region
  name                     = lower("${var.installation_name}-${var.country_code}-dataproc")
  ip_cidr_range            = var.dataproc_subnet_ip4_cidr
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}
