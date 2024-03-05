resource "random_id" "uuid" {
  byte_length = 6
}

resource "google_pubsub_schema" "metric_schema" {
  project = var.data_plane_project
  name       = "metric"
  type       = "AVRO"
  definition = file("${path.module}/schema/metric-schema.json")

}

resource "google_pubsub_topic" "metrics_topic" {
  project = var.data_plane_project
  name    = lower("private.${var.installation_name}.metrics-${random_id.uuid.hex}")

  labels = {
    installation_name = lower(var.installation_name)
    organisation-id   = lower(var.organisation_id)
    tenant-name       = lower(var.name)
  }

  depends_on = [google_pubsub_schema.metric_schema]
  schema_settings {
    schema = "projects/${var.data_plane_project}/schemas/${google_pubsub_schema.metric_schema.name}"
    encoding = "JSON"
  }
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
}

resource "google_pubsub_topic_iam_policy" "metrics_publisher_subscriber_policy" {
  project     = google_pubsub_topic.metrics_topic.project
  topic       = google_pubsub_topic.metrics_topic.name
  policy_data = data.google_iam_policy.metrics_publisher_subscriber.policy_data
}

data "archive_file" "cloud_function_source_code" {
  type        = "zip"
  output_path = "publish_metrics.zip"
  source_dir  = "${path.module}/cloudfunction/publish_metrics/"
}

resource "google_storage_bucket" "cloud_function_bucket" {
  name                        = "${random_id.uuid.hex}-gcf-v2-source"
  location                    = var.storage_location
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "cloud_function_bucket" {
  name   = "publish_metrics.zip"
  bucket = google_storage_bucket.cloud_function_bucket.name
  source = data.archive_file.cloud_function_source_code.output_path
}

resource "google_cloudfunctions2_function" "metric_publish_cloud_function" {
  name        = "${random_id.uuid.hex}-publish-metrics"
  location    = var.gcp_region
  description = "Publish Metrics to Control Plane"

  build_config {
    runtime     = "python39"
    entry_point = "publish_metrics"
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_function_bucket.name
        object = google_storage_bucket_object.cloud_function_bucket.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      TARGET_GOOGLE_CLOUD_PROJECT = var.control_plane_project
      TARGET_TOPIC_NAME           = var.metrics_pubsub_topic
    }
    ingress_settings      = "ALLOW_INTERNAL_ONLY"
    service_account_email = google_service_account.tenant_data_access.email
  }

  event_trigger {
    trigger_region = var.gcp_region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.metrics_topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }

  labels = {
    installation_name = lower(var.installation_name)
    organisation-id   = lower(var.organisation_id)
    tenant-name       = lower(var.name)
  }
}
