variable "organisation_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  description = "Location for Load Balancer and Cloud Run resource"
  type        = string
}

variable "service_account" {
  description = "Cloud Run Service Account"
  type        = string
}

variable "kb_dataset" {
  description = "The Identity-Graph knowledge base (KB) dataset name"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork where Graph-Visualiser will run"
  type        = string
}

variable "authorised_users" {
  type = object({
    groups = set(string)
    users  = set(string)
  })
  description = "The users and groups that can access the Graph Visualiser"
}