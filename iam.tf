# Dataproc Worker
resource "google_project_iam_member" "dataproc_worker" {
  project = var.control_plane_project
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.tenant_orchestration_service_account.email}"
}

# Use build subnet for dataproc jobs
resource "google_compute_subnetwork_iam_member" "vpc_subnetwork_user" {
  subnetwork = var.build_subnet_self_link
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_service_account.tenant_orchestration_service_account.email}"
}

# Create BigQuery jobs (but grants no access to any datasets)
resource "google_project_iam_member" "big_query_job_creator" {
  project = var.data_plane_project
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.tenant_orchestration_service_account.email}"
}

# Required for spark connector to push work down to BigQuery
resource "google_project_iam_member" "portrait_engine_sa_allow_bq_connector_push_down" {
  project = var.data_plane_project
  role    = "roles/bigquery.readSessionUser"
  member  = "serviceAccount:${google_service_account.tenant_orchestration_service_account.email}"
}
