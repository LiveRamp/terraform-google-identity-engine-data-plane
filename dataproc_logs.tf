#### Custom IAM to allow users access to Dataproc job logs via Cloud Logging and Monitoring
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

//TODO check if condition for org Id can be used via labels or otherwise (and if it is needed)
resource "google_project_iam_member" "dataproc_logs_viewer_binding_groups" {
  for_each = toset(var.data_viewers.groups)
  project  = var.data_plane_project
  role     = google_project_iam_custom_role.dataproc_logs_viewer.name
  member   = "group:${each.value}"

  condition {
    title       = "DataprocLogAccess"
    description = "Access to logs from all Dataproc resources"
    expression  = "resource.type == 'cloud_dataproc_job'"
  }
}

resource "google_project_iam_member" "dataproc_logs_viewer_binding_service_accounts" {
  for_each = toset(var.data_viewers.service_accounts)
  project  = var.data_plane_project
  role     = google_project_iam_custom_role.dataproc_logs_viewer.name
  member   = "serviceAccount:${each.value}"

  condition {
    title       = "DataprocLogAccess"
    description = "Access to logs from all Dataproc resources"
    expression  = "resource.type == 'cloud_dataproc_job'"
  }
}

resource "google_project_iam_member" "dataproc_logs_viewer_binding_users" {
  for_each = toset(var.data_viewers.service_accounts)
  project  = var.data_plane_project
  role     = google_project_iam_custom_role.dataproc_logs_viewer.name
  member   = "user:${each.value}"

  condition {
    title       = "DataprocLogAccess"
    description = "Access to logs from all Dataproc resources"
    expression  = "resource.type == 'cloud_dataproc_job'"
  }
}