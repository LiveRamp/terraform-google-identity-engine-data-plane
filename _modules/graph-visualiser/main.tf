locals {
  prefixed_authorised_access = toset(concat(
    [for i in var.authorised_users.groups : "group:${i}"],
    [for i in var.authorised_users.users : "user:${i}"]
  ))
}

data "google_project" "data_plane" {
  project_id = var.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  self_link = var.subnetwork
}

resource "google_project_service" "project_service" {
  project = data.google_project.data_plane.project_id
  service = "iap.googleapis.com"
}

resource "google_cloud_run_v2_service" "graph_visualiser" {
  provider     = google-beta
  name         = "graph-visualiser-${lower(var.organisation_id)}"
  location     = var.region
  ingress      = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  launch_stage = "BETA"
  iap_enabled  = true
  template {
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        subnetwork = data.google_compute_subnetwork.subnetwork.name
        network    = reverse(split("/", data.google_compute_subnetwork.subnetwork.network))[0]
      }
    }
    scaling {
      max_instance_count = 1
      min_instance_count = 0
    }
    service_account = var.service_account
    containers {
      name  = "application"
      image = "us-central1-docker.pkg.dev/liveramp-eng/shared/identity-first-party-graph-backend/dev/identity-graph-visualizer:experimental"
      ports {
        container_port = 8501
      }
      env {
        name  = "PROJECT_ID"
        value = data.google_project.data_plane.project_id
      }
      env {
        name  = "DATASET"
        value = var.kb_dataset
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "graph_visualiser_iap_invoker" {
  depends_on = [google_cloud_run_v2_service.graph_visualiser]
  provider   = google-beta
  project    = google_cloud_run_v2_service.graph_visualiser.project
  location   = google_cloud_run_v2_service.graph_visualiser.location
  name       = google_cloud_run_v2_service.graph_visualiser.name
  role       = "roles/run.invoker"
  member     = "serviceAccount:service-${data.google_project.data_plane.number}@gcp-sa-iap.iam.gserviceaccount.com"
}

resource "google_iap_web_iam_member" "graph_visualiser_user_access" {
  for_each = local.prefixed_authorised_access
  provider = google-beta
  project  = google_cloud_run_v2_service.graph_visualiser.project
  role     = "roles/iap.httpsResourceAccessor"
  member   = each.value
}

resource "google_project_iam_member" "cloud_run_network_user" {
  project = google_cloud_run_v2_service.graph_visualiser.project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${data.google_project.data_plane.number}@serverless-robot-prod.iam.gserviceaccount.com"
}
