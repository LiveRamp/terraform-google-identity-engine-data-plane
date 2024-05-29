resource "google_storage_hmac_key" "this" {
  service_account_email = google_service_account.tenant_data_access.email
}
