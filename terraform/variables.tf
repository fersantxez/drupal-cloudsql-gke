//variables

//master password is undefined for cloudsql and gke

variable "master_password" {}

//project, admin

variable "project" {}
variable "region" {}
variable "zone" {}

//network,security

variable "network" {}
variable "subnetwork" {}
variable "tag" {}

variable "ports" {
  description = "Ports to open in the firewall. FIXME: separate ports_internal and ports_external"
  type        = "list"
  default     = [80, 443, 3306, 8080, 8081, 111, 2049, 1110, 4045]
}

//Storage - Shared filesystem
variable "fs_name" {}

variable "fs_size" {}
variable "fs_mount_path" {}

//cloudsql service account

variable "cloudsql_service_account_name" {}
variable "cloudsql_client_role" {}
variable "create_keys_role" {}

//cloudSQL

variable "cloudsql_instance" {}
variable "cloudsql_username" {}
variable "cloudsql_tier" {}
variable "cloudsql_storage_type" {}
variable "cloudsql_db_version" {}
variable "cloudsql_db_creds_path" {}

//GKE

variable "gke_cluster_name" {}
variable "gke_cluster_version" {}
variable "gke_machine_type" {}
variable "gke_cluster_size" {}
variable "gke_max_cluster_size" {}
variable "gke_username" {}

//GKE service

variable "gke_service_name" {}
variable "gke_app_name" {}
variable "gke_drupal_image" {}
variable "drupal_username" {}
variable "drupal_password" {}
variable "drupal_email" {}
variable "gke_cloudsql_image" {}

//networking

variable "subnetcidr" {}
variable "ext_ip_name" {}
variable "domain" {}
variable "dns_zone_name" {}
variable "dns_name" {}

//data
data "google_compute_zones" "available" {}
