output "tenant_organisation_id" {
  value = var.organisation_id
  description = "The tenant organisation ID"
}

output "tenant_name" {
  value = var.name
  description = "The tenant name"
}

output "tenant_project" {
  value = data.google_project.data_plane_project
  description = "The tenant project object"
}

output "tenant_data_access_svc_account" {
  value       = google_service_account.tenant_data_access
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

output "cloud_nat_static_ip_address_0" {
  value       = try(google_compute_address.cloud_nat_static_ip_address[0].address, null)
  description = "The static IP addresses for Cloud NAT"
}

output "cloud_nat_static_ip_address_1" {
  value       = try(google_compute_address.cloud_nat_static_ip_address[1].address, null)
  description = "The static IP addresses for Cloud NAT"
}

output "dataproc_subnet" {
  value       = try(google_compute_subnetwork.dataproc_subnet, null)
  description = "The ID of the Dataproc subnet"
}