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

//Storage - NFS or other shared filesystems

variable "export_path" {}
variable "disk" {}
variable "raw_disk_type" {}
variable "nfs_machine_type" {}
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

variable "subnetcidr" {}
variable "ext_ip_name" {}
variable "domain" {}
variable "dns_zone_name" {}
variable "dns_name" {}

//data
data "google_compute_zones" "available" {}

//Elastifile
#ECFS - Elastifile

variable "ZONE" {}
variable "PROJECT" {}
variable "CREDENTIALS" {}
variable "SERVICE_EMAIL" {}

variable "DISKTYPE" {
  default = "local"
}

variable "NUM_OF_VMS" {
  default = "3"
}

variable "NUM_OF_DISKS" {
  default = "1"
}

variable "CLUSTER_NAME" {}

variable "IMAGE" {}

variable "SETUP_COMPLETE" {
  default = "false"
}

variable "PASSWORD_IS_CHANGED" {
  default = "false"
}

variable "PASSWORD" {
  default = "changeme"
}
