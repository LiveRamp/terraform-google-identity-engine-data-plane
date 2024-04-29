resource "google_compute_firewall" "allow_metastore_egress" {
  count       = var.enable_dataproc_network ? 1 : 0
  project     = google_compute_network.vpc_network[0].project
  name        = "allow-${var.installation_name}-metastore-egress"
  network     = google_compute_network.vpc_network[0].name
  direction   = "EGRESS"
  priority    = "1000"
  description = "Allow EGRESS to Identity Engine Metastore CloudSQL instance"

  allow {
    protocol = "tcp"

    ports = [
      "3306"
    ]
  }

  destination_ranges = [
    var.metastore_cidr_ip_address
  ]
}

resource "google_compute_firewall" "allow_idapi_egress" {
  count       = var.enable_dataproc_network ? 1 : 0
  project     = google_compute_network.vpc_network[0].project
  name        = "allow-${var.installation_name}-idapi-egress"
  network     = google_compute_network.vpc_network[0].name
  direction   = "EGRESS"
  priority    = "1000"
  description = "Allow EGRESS to LiveRamp ID-API instance"

  allow {
    protocol = "tcp"

    ports = [
      "443"
    ]
  }

  destination_ranges = var.idapi_cidr_ip_addresses
}

resource "google_compute_firewall" "allow_query_engine_egress" {
  depends_on  = [google_compute_network.vpc_network]
  count       = var.enable_dataproc_network ? 1 : 0
  project     = google_compute_network.vpc_network[0].project
  name        = "allow-${var.name}-qe-egress"
  network     = google_compute_network.vpc_network[0].name
  direction   = "EGRESS"
  priority    = "1000"
  description = "Allow EGRESS to LiveRamp api.liveramp.com"

  allow {
    protocol = "tcp"

    ports = [
      "443"
    ]
  }

  destination_ranges = [
    var.query_engine_ip_address
  ]
}

module "dataproc-firewall-rules" {
  count        = var.enable_dataproc_network ? 1 : 0
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "6.0.1"
  project_id   = var.data_plane_project
  network_name = google_compute_network.vpc_network[0].name

  rules = [
    {
      name                    = "${var.installation_name}-dataproc-allow-ingress-from-subnet"
      description             = "Allow Dataproc clusters to communicate over private IP to google APIs and other nodes"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = [var.dataproc_subnet_ip4_cidr]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
          ports    = []
        },
      ]
      deny       = []
      log_config = null
    },
    {
      name                    = "${var.installation_name}-dataproc-allow-egress-to-subnet"
      description             = "Allow Dataproc clusters to communicate over private IP to google APIs and other nodes"
      direction               = "EGRESS"
      priority                = 1000
      ranges                  = [var.dataproc_subnet_ip4_cidr]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
          ports    = []
        },
      ]
      deny       = []
      log_config = null
    }
  ]
}
