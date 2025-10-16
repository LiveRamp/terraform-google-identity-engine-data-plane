locals {
  tenant_service_account_name = lower("${var.name}-${random_id.generator.hex}")
}

resource "random_id" "generator" {
  byte_length = 4
}

resource "google_service_account" "tenant_data_access" {
  project     = var.data_plane_project
  account_id  = local.tenant_service_account_name
  description = "Tenant data access serviceAccount for = ${var.installation_name} - ${title(var.name)} ${upper(var.country_code)}"
}