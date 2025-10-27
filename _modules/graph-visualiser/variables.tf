variable "organisation_id" {
  description = "The LiveRamp organisation id"
  type        = string
}

variable "project_id" {
  type = string
}

variable "region" {
  description = "Location for Cloud Run resource"
  type        = string
}

variable "service_account" {
  description = "Cloud Run Service Account; This account must have read access to the KB"
  type        = string
}

variable "kb_dataset" {
  description = "The Identity-Graph knowledge base (KB) dataset name"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork where Graph-Visualiser will run (self_link format)"
  type        = string
}

variable "authorised_users" {
  type = object({
    groups = set(string)
    users  = set(string)
  })
  description = "The users and groups that can access the Graph Visualiser"
  default = {
    groups = []
    users  = []
  }
}
