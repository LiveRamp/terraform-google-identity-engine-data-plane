output "tenant_organisation_id" {
  value = var.organisation_id
}

output "tenant_name" {
  value = var.name
}

output "tenant_project_id" {
  value = data.google_project.data_plane_project.id
}

output "tenant_project_name" {
  value = data.google_project.data_plane_project.name
}

output "tenant_project_number" {
  value = data.google_project.data_plane_project.number
}

output "tenant_data_access_service_account_email" {
  value       = google_service_account.tenant_data_access.email
  description = "The service account object that will be used to access the tenant data"
}

output "tenant_bigquery_dataset_name" {
  value       = google_bigquery_dataset.tenant_dataset.dataset_id
  description = "The name of the BigQuery dataset that will be used to store the tenant data"
}

output "input_bucket_name" {
  value       = google_storage_bucket.tenant_input_bucket.name
  description = "The name of the GCS bucket that will be used to store the input files"
}

output "build_bucket_name" {
  value       = google_storage_bucket.tenant_build_bucket.name
  description = "The name of the GCS bucket that will be used to store the build files"
}

output "output_bucket_name" {
  value       = google_storage_bucket.tenant_output_bucket.name
  description = "The name of the GCS bucket that will be used to store the output files"
}

output "tenant_hmac_key_id" {
  value = google_storage_hmac_key.this.id
}
