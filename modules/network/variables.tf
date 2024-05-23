variable "installation_name" {
    type = string
}

variable "country_code" {
    type = string
}

variable "project_id" {
    type = string
}

variable "region" {
    type = string
}

variable "network_name" {
    type = string
}

variable "subnet_ip4_cidr" {
    type = string
}

variable "subnet_user" {
    type = string
}

variable "metastore_cidr_ip_address" {
  type        = string
}

variable "idapi_cidr_ip_addresses" {
  type        = list(string)
  default     = []
}
