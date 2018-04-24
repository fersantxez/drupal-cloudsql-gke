//variables

//master password is undefined for cloudsql and gke

variable "master_password" {}

//project, admin

variable "project" {}
variable "region" {}
variable "zone" {}
variable "num_instances" {}

//network,security

variable "network" {}
variable "subnetwork" {}
variable "tag" {}

variable "ports" {
  description = "Ports the HTTP server listens on to be allowd in the external firewall"
  type        = "list"
  default     = [80, 443, 8080, 8081]
}

//Storage - NFS or other shared filesystems

variable "export_path" {}
variable "snapshot" {}
variable "disk" {}
variable "vol_1" {}
variable "vol_1_size" {}
variable "vol_2" {}
variable "vol_2_size" {}
variable "device_name" {}

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
variable "gke_username" {}

//GKE service

variable "gke_service_name" {}
variable "gke_app_name" {}
variable "gke_drupal_image" {}
variable "drupal_username" {}
variable "drupal_password" {}
variable "drupal_email" {}
variable "gke_cloudsql_image" {}

//variable "gke_cloudsql_command" {
//  description = "command to run on the cloudsql container"
//  type        = "list"
//  default     = ["/cloud_sql_proxy", "--dir=/cloudsql", "-instances=MYINSTANCENAME=tcp:3306", "-credential_file=/secrets/cloudsql/credentials.json"]
//}

//
//    "-instances=${google_sql_database_instance.master.self_link}=tcp:3306",

variable "gke_vol_1_name" {}
variable "gke_vol_1_mount_path" {}
variable "gke_vol_2_name" {}
variable "gke_vol_2_mount_path" {}

//networking

variable "ext_ip_name" {}
variable "domain" {}
variable "dns_zone_name" {}
variable "dns_name" {}

//data
data "google_compute_zones" "available" {}
