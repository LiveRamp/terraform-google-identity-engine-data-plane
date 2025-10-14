output "graph_visualiser_service_name" {
  value = google_cloud_run_v2_service.graph_visualiser.name
}

output "graph_visualiser_uri" {
  value = google_cloud_run_v2_service.graph_visualiser.uri
}
