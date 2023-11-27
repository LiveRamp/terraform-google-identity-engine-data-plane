data "google_service_account" "ingestion_service_account" {
  account_id = var.ingestion_service_account_name
}
