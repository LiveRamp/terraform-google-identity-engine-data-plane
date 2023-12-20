module "bigquery_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  count   = var.enable_bigquery ? 1 : 0
  version = "~> 7.0"

  dataset_id   = replace(lower("${var.installation_name}_${var.name}_${var.country_code}"), "-", "_")
  dataset_name = "${title(var.name)} ${upper(var.country_code)} dataset"
  description  = "This dataset is for ${title(var.name)} ${upper(var.country_code)}"
  project_id   = var.data_plane_project
  location     = var.storage_location

  encryption_key = var.enable_kms ? google_kms_crypto_key.tenant_crypto_key[count.index].id : null
  dataset_labels = {
    organisation-id = lower(var.organisation_id)
    tenant-name     = lower(var.name)
    country         = lower(var.country_code)
  }

  access = [
    {
      "role" : "OWNER"
      "special_group" : "projectOwners"
    },
    {
      "role" : "WRITER"
      "user_by_email" : google_service_account.tenant_data_access.email
    }
  ]
}
