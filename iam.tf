resource "google_project_iam_member" "serviceAccount_user" {
  project = var.data_plane_project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.tenant_data_access.email}"
}

resource "google_project_iam_member" "dataproc_worker" {
  project = var.data_plane_project
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.tenant_data_access.email}"
}

resource "google_project_iam_member" "dataproc_editor" {
  project = var.data_plane_project
  role    = "roles/dataproc.editor"
  member  = "serviceAccount:${google_service_account.tenant_data_access.email}"
}

resource "google_compute_subnetwork_iam_member" "vpc_subnetwork_user" {
  count      = var.enable_dataproc_network ? 1 : 0
  project    = var.data_plane_project
  subnetwork = google_compute_subnetwork.dataproc_subnet[0].name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_service_account.tenant_data_access.email}"
}

resource "google_project_iam_member" "bigquery_job_creator" {
  project = var.data_plane_project
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.tenant_data_access.email}"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = var.data_plane_project
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.tenant_data_access.email}"
}

# Required for spark connector to push work down to BigQuery
resource "google_project_iam_member" "allow_bq_connector_push_down" {
  project = var.data_plane_project
  role    = "roles/bigquery.readSessionUser"
  member  = "serviceAccount:${google_service_account.tenant_data_access.email}"
}

resource "google_service_account_iam_member" "tenant_orchestration_impersonate_tenant_data_access_sa" {
  service_account_id = google_service_account.tenant_data_access.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.tenant_orchestration_sa}"
}

#### Custom IAM to allow users access to Dataproc logs via Cloud Logging and Monitoring (FKA Stack Driver)
resource "google_project_iam_custom_role" "dataproc_logs_viewer" {
  role_id     = "dataprocLogsViewer"
  title       = "Dataproc Logs Viewer"
  description = "Role to view logs for all Dataproc resources"
  project     = var.data_plane_project

  permissions = [
    "logging.logEntries.list",
    "logging.logEntries.view",
    "logging.logs.list",
    "logging.logServiceIndexes.list"
  ]
}

resource "google_project_iam_member" "dataproc_logs_viewer_binding" {
  for_each = toset(var.data_viewers.groups)
  project = var.data_plane_project
  role    = google_project_iam_custom_role.dataproc_logs_viewer.name
  member   = "user:${each.value}"

  condition {
    title       = "DataprocLogAccess"
    description = "Access to logs from all Dataproc resources"
    expression  = "resource.type == 'cloud_dataproc_job'"
  }

  //TODO check if condition for org Id can be used via labels or otherwise (and if it is needed)
}