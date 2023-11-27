// create kubernetes service account using organisation-id as name
resource "kubernetes_namespace" "tenant_namespace" {
  metadata {
    name = lower(var.organisation_id)
    labels = {
      tenantName = var.name
      part-of    = "portrait-engine"
      component  = "data-plane"
    }
  }
}

// create KSA in that namespace
resource "kubernetes_service_account" "tenant_ksa" {
  metadata {
    name        = var.control_plane_service_account
    namespace   = kubernetes_namespace.tenant_namespace.metadata[0].name
    annotations = { "iam.gke.io/gcp-service-account" : "${google_service_account.tenant_orchestration_service_account.email}" }
    labels = {
      part-of   = "portrait-engine"
      component = "data-plane"
    }
  }
}

// IAM to connect to Workload Identity
resource "google_service_account_iam_member" "tenant_dataplane_workload_identity" {
  service_account_id = google_service_account.tenant_orchestration_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.control_plane_project}.svc.id.goog[${kubernetes_namespace.tenant_namespace.metadata[0].name}/${kubernetes_service_account.tenant_ksa.metadata[0].name}]"
}

resource "google_project_iam_member" "tenant_dataplane_service_account_user" {
  project = var.control_plane_project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.tenant_orchestration_service_account.email}"
}

resource "google_project_iam_member" "tenant_dataplane_dataproc_editor" {
  project = var.control_plane_project
  role    = "roles/dataproc.editor"
  member  = "serviceAccount:${google_service_account.tenant_orchestration_service_account.email}"
}

resource "google_project_iam_member" "tenant_dataplane_dataproc_worker" {
  project = var.control_plane_project
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.tenant_orchestration_service_account.email}"
}

resource "google_project_iam_member" "tenant_dataplane_bigquery_job_user" {
  project = var.control_plane_project
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.tenant_orchestration_service_account.email}"
}
