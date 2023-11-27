data "google_project" "control_plane_project" {
  project_id = var.control_plane_project
}

data "google_project" "data_plane_project" {
  project_id = var.data_plane_project
}

data "google_storage_project_service_account" "data_plane_gcs_account" {
  project = var.data_plane_project
}

locals {
  # https://cloud.google.com/dataproc/docs/concepts/configuring-clusters/network#creating_a_cluster_that_uses_a_vpc_network_in_another_project
  prefixed_dataproc_service_agent_mail = "serviceAccount:service-${data.google_project.control_plane_project.number}@dataproc-accounts.iam.gserviceaccount.com"

  # BigQuery encryption service account for use with KMS
  prefixed_big_query_kms_user = "serviceAccount:bq-${data.google_project.data_plane_project.number}@bigquery-encryption.iam.gserviceaccount.com"

  # Prefixed ingestion service account
  prefixed_ingestion_service_account_email = "serviceAccount:${data.google_service_account.ingestion_service_account.email}"

  # Create list of all reader users, service accounts and groups with their associated prefix
  prefixed_reader_list = concat(
    [for i in var.data_viewers.groups : "group:${i}"],
    [for i in var.data_viewers.service_accounts : "serviceAccount:${i}"],
    [for i in var.data_viewers.users : "user:${i}"]
  )

  # Create list of all reader users, service accounts and groups with their associated prefix
  prefixed_editor_list = concat(
    [for i in var.data_editors.groups : "group:${i}"],
    [for i in var.data_editors.service_accounts : "serviceAccount:${i}"],
    [for i in var.data_editors.users : "user:${i}"]
  )

}