### --------- DEPRECATED OUTPUTS --------
output "tenant_name" {
  value       = var.name
  description = "DEPRECATED :: for removal"
}

output "tenant_organisation_id" {
  value       = var.organisation_id
  description = "DEPRECATED: use organisation_id"
}

output "tenant_project" {
  value       = data.google_project.data_plane_project
  description = "The tenant project object"
}

output "tenant_data_access_svc_account" {
  value       = google_service_account.tenant_data_access
  description = "DEPRECATED :: use data_access_service_account_email"
}

output "tenant_data_access_email" {
  value       = "google_service_account.tenant_data_access.email"
  description = "DEPRECATED :: use data_access_service_account_email"
}

output "tenant_bigquery_dataset_name" {
  value       = google_bigquery_dataset.tenant_dataset.dataset_id
  description = "DEPRECATED :: use dataset_id"
}

output "dataproc_subnet" {
  value       = try(google_compute_subnetwork.dataproc_subnet[0].name, "")
  description = "DEPRECATED"
}


### ----- END OF DEPRECATED OUTPUTS -----


output "organisation_id" {
  value       = var.organisation_id
  description = "LiveRamp/Organisation ID"
}

output "project_id" {
  value       = data.google_project.data_plane_project.project_id
  description = "The project information"
}

output "data_access_service_account_email" {
  value       = google_service_account.tenant_data_access.email
  description = "The data access service account"
}

output "dataset_id" {
  value       = google_bigquery_dataset.tenant_dataset.dataset_id
  description = "KB dataset"
}

output "build_bucket_name" {
  value       = google_storage_bucket.tenant_build_bucket.name
  description = "The name of the GCS bucket that will be used to store the build files"
}


// --------------------------------------------------------------------------------------------------------


output "cloud_nat_static_ip_address_0" {
  value       = try(google_compute_address.cloud_nat_static_ip_address[0].address, "")
  description = "The first static IP address for Cloud NAT"
}

output "cloud_nat_static_ip_address_1" {
  value       = try(google_compute_address.cloud_nat_static_ip_address[1].address, "")
  description = "The second static IP address for Cloud NAT"
}

output "subnetwork" {
  value       = try(google_compute_subnetwork.dataproc_subnet[0].name, "")
  description = "The data-plane subnetwork"
}
