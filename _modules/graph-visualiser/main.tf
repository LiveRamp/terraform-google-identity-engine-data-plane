resource "google_cloud_run_v2_service" "graph_visualiser" {
  name     = "graph-visualiser-${lower(var.organisation_id)}"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  template {
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
        value = var.project_id
      }
      env {
        name  = "DATASET"
        value = var.kb_dataset
      }
    }
  }
}
