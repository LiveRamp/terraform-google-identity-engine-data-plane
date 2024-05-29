resource "google_storage_hmac_key" "tenant_query_engine_access" {
  service_account_email = google_service_account.tenant_data_access.service_account.email
}
