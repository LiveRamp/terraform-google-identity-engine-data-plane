output "tenant_data_access_email" {
  value = google_service_account.tenant_data_access.email
}

output "tenant_data_access_svc_account_id" {
  value = google_service_account.tenant_data_access.id
}
