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
