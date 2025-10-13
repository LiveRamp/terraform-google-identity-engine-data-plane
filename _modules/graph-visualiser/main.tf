data "google_project" "data_plane" {
  project_id = var.project_id
}

data "google_compute_network" "network" {
  project = var.project_id
  name    = var.network
}

resource "google_project_service" "project_service" {
  project = data.google_project.data_plane.id
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
        network = data.google_compute_network.network.id
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
        value = data.google_project.data_plane.id
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
  for_each = var.authorised_users
  provider = google-beta
  project  = google_cloud_run_v2_service.graph_visualiser.project
  role     = "roles/iap.httpsResourceAccessor"
  member   = "user:${each.value}"
}
