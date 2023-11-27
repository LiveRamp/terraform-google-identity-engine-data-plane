module "access_level_allow_list" {
  count   = var.service_perimeter.configure ? 1 : 0
  source  = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version = "5.0.0"
  policy  = var.service_perimeter.org_access_policy_id
  name    = "access_level_allow_list"
  members = var.service_perimeter.allow_list_identities
}

resource "null_resource" "wait_for_members" {
  count = var.service_perimeter.configure ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 60"
  }

  depends_on = [module.access_level_allow_list]
}

data "google_project" "projects" {
  for_each   = var.service_perimeter.perimeter_projects
  project_id = each.value
}

module "regular_svc_perimeter" {
  source         = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version        = "5.0.0"
  policy         = var.service_perimeter.org_access_policy_id
  perimeter_name = "regular_svc_perimeter_remote_execution"
  description    = "VPC Service Perimeter for Remote Execution"

  for_each            = var.service_perimeter.configure ? data.google_project.projects : {}
  resources           = [each.value.number]
  restricted_services = var.service_perimeter.restricted_services

  # access_levels = [module.access_level_allow_list.name]
  ingress_policies = var.service_perimeter.ingress_policies
  egress_policies  = var.service_perimeter.egress_policies
  depends_on       = [null_resource.wait_for_members]
}
