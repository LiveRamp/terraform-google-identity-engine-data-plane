
locals {
  groups_log_viewers = toset(var.data_viewers.groups, var.data_editors.groups)
  users_log_viewers  = toset(var.data_viewers.users, var.data_editors.users)
}

resource "google_project_iam_member" "groups_log_viewers" {
  for_each = local.groups_log_viewers
  project  = var.data_plane_project
  role     = "roles/logging.viewer"
  member   = "group:${each.value}"

  condition {
    title       = "DataprocLogAccess"
    description = "Access to logs from all Dataproc resources"
    expression  = "resource.type == 'cloud_dataproc_job'"
  }
}

resource "google_project_iam_member" "users_log_viewers" {
  for_each = local.users_log_viewers
  project  = var.data_plane_project
  role     = "roles/logging.viewer"
  member   = "user:${each.value}"

  condition {
    title       = "DataprocLogAccess"
    description = "Access to logs from all Dataproc resources"
    expression  = "resource.type == 'cloud_dataproc_job'"
  }
}