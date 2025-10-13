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

variable "authorised_users" {
  description = "Authorised users to access Graph-Visualiser"
  type        = set(string)
  default     = []
}

variable "network" {
  description = "The network where Graph-Visualiser will run"
  type        = string
}