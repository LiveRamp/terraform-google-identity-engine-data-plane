# Create a orchestration service-account specific to a tenant
resource "google_service_account" "tenant_orchestration_service_account" {
  project     = var.control_plane_project
  account_id  = lower("${var.name}-${var.country_code}")
  description = "Tenant orchestration serviceAccount for = ${var.installation_name} - ${title(var.name)} ${upper(var.country_code)}"
}