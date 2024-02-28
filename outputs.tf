output "tenant_data_access_svc_account_name" {
  value = google_service_account.tenant_data_access.name
}

output "tenant_bigquery_dataset_name" {
  value = google_bigquery_dataset.tenant_dataset.dataset_id
}

output "input_bucket_name" {
  value = google_storage_bucket.tenant_input_bucket.name
}

output "build_bucket_name" {
  value = google_storage_bucket.tenant_build_bucket.name
}

output "output_bucket_name" {
  value = google_storage_bucket.tenant_output_bucket.name
}
