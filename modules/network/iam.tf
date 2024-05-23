resource "google_compute_subnetwork_iam_member" "subnet_user" {
  project    = var.project_id
  subnetwork = google_compute_subnetwork.dataproc_subnet.name
  role       = "roles/compute.networkUser"
  member     = var.subnet_user
}
