locals {
  default_bigquery_dataset_name = replace(lower("${var.installation_name}_${var.name}_${var.country_code}"), "-", "_")
  bigquery_dataset_name         = coalesce(var.bigquery_dataset_name, local.default_bigquery_dataset_name)
}

resource "google_bigquery_connection" "bq_spark_connection" {
  connection_id = "bq-spark-conn-${lower(var.organisation_id)}-${lower(var.country_code)}"
  location      = var.storage_location
  description   = "BQ spark connection for ML"
  spark {
    spark_history_server_config {
      dataproc_cluster = google_dataproc_cluster.dataproc_persistent_history_server.id
    }
  }
}

resource "google_dataproc_cluster" "dataproc_persistent_history_server" {
  name   = "bq-spark-conn-cluster-${lower(var.organisation_id)}-${lower(var.country_code)}"
  region = var.gcp_region

  cluster_config {
    software_config {
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
      }
    }

    master_config {
      num_instances = 1
      machine_type  = "e2-standard-2"
      disk_config {
        boot_disk_size_gb = 50
      }
    }
  }
}

resource "google_bigquery_connection_iam_binding" "binding" {
  project = var.data_plane_project
  location = google_bigquery_connection.bq_spark_connection.location
  connection_id = google_bigquery_connection.bq_spark_connection.connection_id
  role = "roles/bigquery.connections.use"
  members = toset(concat(
    [for i in var.data_editors.groups : "group:${i}"],
    [for i in var.data_editors.service_accounts : "serviceAccount:${i}"],
    [for i in var.data_editors.users : "user:${i}"]
  ))
}

resource "google_bigquery_dataset" "tenant_dataset" {
  project       = var.data_plane_project
  dataset_id    = local.bigquery_dataset_name
  friendly_name = "${title(var.name)} ${upper(var.country_code)} dataset"
  description   = "This dataset is for ${title(var.name)} ${upper(var.country_code)}"
  location      = var.storage_location

  dynamic "default_encryption_configuration" {
    for_each = var.enable_kms ? [google_kms_crypto_key.tenant_crypto_key[0].id] : []
    content {
      kms_key_name = google_kms_crypto_key.tenant_crypto_key[0].id
    }
  }

  default_partition_expiration_ms = var.data_retention_period_days * 86400000

  labels = {
    organisation-id = lower(var.organisation_id)
    tenant-name     = lower(var.name)
    country         = lower(var.country_code)
  }

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  dynamic "access" {
    for_each = toset(concat(
      [google_service_account.tenant_data_access.email],
      var.data_editors.users,
      var.data_editors.service_accounts
    ))
    content {
      role          = "WRITER"
      user_by_email = access.value
    }
  }

  dynamic "access" {
    for_each = toset(var.data_editors.groups)
    content {
      role           = "WRITER"
      group_by_email = access.value
    }
  }

  dynamic "access" {
    for_each = toset(concat(
      var.data_viewers.users,
      var.data_viewers.service_accounts
    ))
    content {
      role          = "READER"
      user_by_email = access.value
    }
  }

  dynamic "access" {
    for_each = toset(var.data_viewers.groups)
    content {
      role           = "READER"
      group_by_email = access.value
    }
  }

  depends_on = [
    google_kms_crypto_key.tenant_crypto_key, module.kms_crypto_key-iam-bindings
  ]
}
