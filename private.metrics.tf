resource "google_pubsub_schema" "metric_schema" {
  project    = var.data_plane_project
  name       = lower("metric-${var.organisation_id}")
  type       = "AVRO"
  definition = file("${path.module}/schema/metric-schema.json")
  count      = var.enable_metrics_infra ? 1 : 0
}

resource "google_pubsub_topic" "metrics_topic" {
  project = var.data_plane_project
  name    = lower("private.${var.organisation_id}.metrics.v1")

  labels = {
    installation_name = lower(var.installation_name)
    organisation-id   = lower(var.organisation_id)
    tenant-name       = lower(var.name)
  }

  depends_on = [google_pubsub_schema.metric_schema]
  schema_settings {
    schema   = "projects/${var.data_plane_project}/schemas/${google_pubsub_schema.metric_schema[0].name}"
    encoding = "JSON"
  }

  count = var.enable_metrics_infra ? 1 : 0
}

data "google_iam_policy" "metrics_publisher_subscriber" {
  binding {
    role = "roles/pubsub.publisher"
    members = concat([
      "serviceAccount:${google_service_account.tenant_data_access.email}"
    ])
  }

  binding {
    role = "roles/pubsub.subscriber"
    members = concat([
      "serviceAccount:${google_service_account.tenant_data_access.email}"
    ])
  }
  count = var.enable_metrics_infra ? 1 : 0
}

resource "google_pubsub_topic_iam_policy" "metrics_publisher_subscriber_policy" {
  project     = google_pubsub_topic.metrics_topic[0].project
  topic       = google_pubsub_topic.metrics_topic[0].name
  policy_data = data.google_iam_policy.metrics_publisher_subscriber[0].policy_data
  count       = var.enable_metrics_infra ? 1 : 0
}

data "archive_file" "cloud_function_source_code" {
  type        = "zip"
  output_path = "publish_metrics.zip"
  source_dir  = "${path.module}/cloudfunction/publish_metrics/"
  count       = var.enable_metrics_infra ? 1 : 0
}

resource "google_storage_bucket" "cloud_function_bucket" {
  name                        = lower("${var.organisation_id}-${var.country_code}-${var.environment}-gcf-v2-source")
  location                    = var.storage_location
  uniform_bucket_level_access = true
  count                       = var.enable_metrics_infra ? 1 : 0
}

resource "google_storage_bucket_object" "cloud_function_source" {
  name   = "publish_metrics.zip"
  bucket = google_storage_bucket.cloud_function_bucket[0].name
  source = data.archive_file.cloud_function_source_code[0].output_path
  count  = var.enable_metrics_infra ? 1 : 0
}

resource "google_cloudfunctions_function" "metric_publish_cloud_function_2" {
  project               = var.data_plane_project
  name                  = lower("publish-metrics-fn-${var.organisation_id}")
  source_archive_bucket = google_storage_bucket.cloud_function_bucket[0].name
  source_archive_object = google_storage_bucket_object.cloud_function_source[0].name
  description           = "Publish Metrics to Control Plane"
  entry_point           = "publish_metrics"
  region                = var.gcp_region
  available_memory_mb   = 256
  timeout               = 60
  max_instances         = 3
  min_instances         = 1
  runtime               = "python39"

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.metrics_topic[0].id

    failure_policy {
      retry = true
    }

  }

  service_account_email = google_service_account.tenant_data_access.email
  ingress_settings      = "ALLOW_INTERNAL_ONLY"

  environment_variables = {
    TARGET_GOOGLE_CLOUD_PROJECT = var.control_plane_project
    TARGET_TOPIC_NAME           = var.control_plane_metrics_pubsub_topic
  }

  labels = {
    installation_name = lower(var.installation_name)
    organisation-id   = lower(var.organisation_id)
    tenant-name       = lower(var.name)
  }

  count = var.enable_metrics_infra ? 1 : 0
}