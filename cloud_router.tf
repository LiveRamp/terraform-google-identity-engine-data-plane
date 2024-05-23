resource "google_compute_address" "cloud_nat_static_ip_address" {
  project = var.data_plane_project
  region  = var.gcp_region
  count   = var.enable_dataproc_network ? 2 : 0
  name    = lower("${var.installation_name}-${var.gcp_region}-nat-ip-${count.index}")
}

module "cloud_router" {
  count   = var.enable_dataproc_network ? 1 : 0
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"
  name    = lower("${var.installation_name}-${var.gcp_region}-router")
  project = var.data_plane_project
  network = google_compute_network.vpc_network[0].name
  region  = var.gcp_region

  nats = [{
    name                               = lower("${var.installation_name}-${var.gcp_region}-nat")
    nat_ip_allocate_option             = "MANUAL_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    nat_ips                            = google_compute_address.cloud_nat_static_ip_address.*.self_link
    min_ports_per_vm                   = 256 # Increased from default of 64
    tcp_established_idle_timeout_sec   = 300 # Decreased from default of 1200s
    tcp_transitory_idle_timeout_sec    = 180 # Increased from default of 30s

    log_config = {
      enable = true
      filter = "ERRORS_ONLY"
    }
  }]
}
