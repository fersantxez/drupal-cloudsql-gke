//variables

//project, admin
variable "project_name" {}

variable "region" {}
variable "zone" {}
variable "num_instances" {}
variable "name" {}

//network,security
variable "network" {}

variable "tag" {}

variable "ports" {
  description = "Ports the HTTP server listens on"
  type        = "list"
  default     = [8080, 8081]
}

//NFS
variable "nfs_export_path" {}

variable "nfs_vol_1" {}
variable "nfs_vol_2" {}
variable "nfs_disk" {}
variable "nfs_blank_volume" {}

//service account
variable "service_account_name" {}

variable "service_account_description" {}
variable "service_account_role" {}

//cloudSQL
variable "cloudsql_instance" {}

variable "cloudsql_username" {}
variable "cloudsql_tier" {}
variable "cloudsql_storage_type" {}
variable "cloudsql_db_version" {}

//data
data "google_compute_zones" "available" {}
