resource "google_pubsub_topic" "metrics" {
  project = var.data_plane_project
  name    = lower("private.${var.installation_name}.metrics")

  labels = {
    installation_name = var.installation_name
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
  project     = google_pubsub_topic.metrics.project
  topic       = google_pubsub_topic.metrics.name
  policy_data = data.google_iam_policy.metrics_publisher_subscriber.policy_data
}

//Cloudfunction
resource "google_storage_bucket" "cloudfunction_bucket" {
  name                        = "${var.data_plane_project}-gcf-v2-source"
  location                    = var.storage_location
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "source" {
  name   = "publish_metrics.zip"
  bucket = google_storage_bucket.cloudfunction_bucket.name
  source = "../cloudfunction/publish_metrics/publish_metrics.zip"
}

resource "google_cloudfunctions2_function" "default" {
  name        = "publish-metrics"
  location    = var.gcp_region
  description = "Publish Metrics to Control Plane"

  build_config {
    runtime     = "python39"
    entry_point = "publish_metrics"
    source {
      storage_source {
        bucket = google_storage_bucket.cloudfunction_bucket.name
        object = google_storage_bucket_object.source.name
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
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.tenant_data_access.email
  }

  event_trigger {
    trigger_region = var.gcp_region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.metrics.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}
