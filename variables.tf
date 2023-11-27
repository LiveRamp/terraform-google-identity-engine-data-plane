variable "organisation_id" {
  type        = string
  description = "Liveramp CAC/Organisation-id"
}

variable "installation_name" {
  type    = string
  default = "portrait-engine"
}

variable "name" {
  type        = string
  description = "The human readable customer name"
}

variable "country_code" {
  type        = string
  description = "The ISO 3166-1 two character country code (https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes)"
}

variable "environment" {
  type        = string
  description = "The environment this infrastructure is supported (One of: dev, staging or prod)"

  validation {
    condition     = contains(["dev", "demo", "staging", "prod"], var.environment)
    error_message = "Valid values for var: environment are (dev, demo, staging, prod)."
  }
}

variable "control_plane_project" {
  type        = string
  description = "The GCP project in which customer data will be processed."
}

variable "control_plane_service_account" {
  type        = string
  default     = "orchestration"
  description = "Kubernetes Service Account name to configure WorkloadIdentity with the Control-Plane/Google-Service-Account"
}

variable "data_plane_project" {
  type        = string
  description = "The GCP project in which customer data will be stored."
}

variable "storage_location" {
  type        = string
  description = "The storage location for BigQuery and GCS."
}

variable "kms_self_link" {
  type        = string
  description = "The KMS instance to store this customer & countries key in"
}

variable "build_subnet_self_link" {
  type        = string
  description = "The self link to the regional subnet this customer should use"
}

variable "network_self_link" {
  type    = string
  default = null
}

variable "data_editors" {
  type = object({
    service_accounts = list(string)
    groups           = list(string)
    users            = list(string)
  })
  description = "The users, groups & service accounts that should have read & write access to this customers data"
}

variable "data_viewers" {
  type = object({
    service_accounts = list(string)
    groups           = list(string)
    users            = list(string)
  })
  description = "The users, groups & service accounts that should have read only access to this customers data"
}

variable "ingestion_service_account_name" {
  type        = string
  description = "The service account attached to the cloud function that will copy customer data to this bucket."
}

variable "data_retention_period_days" {
  type        = number
  description = "The number of days this customers data will be stored before its automatically deleted"
  default     = 0
}

variable "key_rotation_period_days" {
  type        = number
  description = "The frequency at which the crypto key will automatically rotate (days)"
  default     = 90
}
