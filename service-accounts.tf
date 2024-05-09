resource "random_id" "generator" {
  byte_length = 4
}

resource "google_service_account" "tenant_data_access" {
  project     = var.data_plane_project
  account_id  = lower("${var.name}-${random_id.generator.hex}")
  description = "Tenant data access serviceAccount for = ${var.installation_name} - ${title(var.name)} ${upper(var.country_code)}"
}

resource "google_storage_hmac_key" "tenant_query_engine_access" {
  count                 = var.enable_liveramp_query_engine ? 1 : 0
  service_account_email = tenant_data_access.service_account.email
}