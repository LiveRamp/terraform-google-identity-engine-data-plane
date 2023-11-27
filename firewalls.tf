resource "google_compute_firewall" "allow_portrait_engine_metastore_egress" {
  project     = google_compute_network.vpc_network.project
  name        = "allow-${var.installation_name}-metastore-egress"
  network     = google_compute_network.vpc_network.name
  direction   = "EGRESS"
  priority    = "1000"
  description = "Allow EGRESS to Portrait Engine Metastore CloudSQL instance"

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

resource "google_compute_firewall" "allow_portrait_engine_idapi_egress" {
  project     = google_compute_network.vpc_network.project
  name        = "allow-${var.installation_name}-idapi-egress"
  network     = google_compute_network.vpc_network.name
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