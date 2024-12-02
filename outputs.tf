output "tenant_organisation_id" {
  value       = var.organisation_id
  description = "The tenant organisation ID"
}

output "tenant_name" {
  value       = var.name
  description = "The tenant name"
}

output "tenant_project" {
  value       = data.google_project.data_plane_project
  description = "The tenant project object"
}

output "tenant_data_access_svc_account" {
  value       = google_service_account.tenant_data_access
  description = "The service account object that will be used to access the tenant data"
}

output "tenant_data_access_email" {
  value       = "google_service_account.tenant_data_access.email"
  description = "The access email to be impersonated when operating in the tenant data-plane"
}

output "tenant_bigquery_dataset_name" {
  value       = google_bigquery_dataset.tenant_dataset.dataset_id
  description = "The name of the BigQuery dataset that will be used to store the tenant data"
}

output "build_bucket_name" {
  value       = google_storage_bucket.tenant_build_bucket.name
  description = "The name of the GCS bucket that will be used to store the build files"
}

output "cloud_nat_static_ip_address_0" {
  value       = try(google_compute_address.cloud_nat_static_ip_address[0].address, "")
  description = "The first static IP address for Cloud NAT"
}

output "cloud_nat_static_ip_address_1" {
  value       = try(google_compute_address.cloud_nat_static_ip_address[1].address, "")
  description = "The second static IP address for Cloud NAT"
}

output "dataproc_subnet" {
  value       = try(google_compute_subnetwork.dataproc_subnet[0].name, "")
  description = "The ID of the Dataproc subnet"
}
