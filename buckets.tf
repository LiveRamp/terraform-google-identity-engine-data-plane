locals {
  buckets = {
    input_bucket  = lower("${var.installation_name}-${var.environment}-${var.name}-${var.country_code}-input")
    build_bucket  = lower("${var.installation_name}-${var.environment}-${var.name}-${var.country_code}-build")
    output_bucket = lower("${var.installation_name}-${var.environment}-${var.name}-${var.country_code}-output")
  }
}

module "gcs_buckets" {
  source        = "terraform-google-modules/cloud-storage/google"
  count         = var.enable_buckets ? 1 : 0
  version       = "~> 5.0"
  project_id    = var.data_plane_project
  location      = var.storage_location
  storage_class = "STANDARD"
  names = [
    local.buckets.input_bucket,
    local.buckets.build_bucket,
    local.buckets.output_bucket
  ]
  prefix               = ""
  encryption_key_names = var.enable_kms ? { default_kms_key_name = google_kms_crypto_key.tenant_crypto_key[count.index].id } : {}
  versioning = {
    "${local.buckets.input_bucket}"  = false
    "${local.buckets.build_bucket}"  = false
    "${local.buckets.output_bucket}" = false
  }
  lifecycle_rules = [
    {
      condition = {
        age = var.data_retention_period_days
      }
      action = {
        type = "Delete"
      }
    }
  ]
  labels = {
    organisation-id = lower(var.organisation_id)
    tenant-name     = lower(var.name)
    country         = lower(var.country_code)
    component       = "data-plane"
    part-of         = "portrait-engine"
    installation    = var.installation_name
  }
}

module "storage_bucket-iam-bindings" {
  source = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  storage_buckets = [
    local.buckets.input_bucket,
    local.buckets.build_bucket,
    local.buckets.output_bucket
  ]
  mode = "authoritative"

  bindings = {
    "roles/storage.admin" = [
      "projectOwner:${var.data_plane_project}"
    ]
    "roles/storage.objectAdmin" = concat(
      local.prefixed_editor_list,
      ["serviceAccount:${google_service_account.tenant_data_access.email}"]
    )
    "roles/storage.objectViewer" = concat(
      local.prefixed_reader_list,
      [local.prefixed_dataproc_service_agent_mail]
    )
    "roles/storage.legacyBucketReader" = concat(
      local.prefixed_editor_list,
      local.prefixed_reader_list,
      [local.prefixed_dataproc_service_agent_mail],
      ["serviceAccount:${google_service_account.tenant_data_access.email}"]
    )
  }
}
