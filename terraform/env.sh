#!/bin/bash

##### CONFIGURE THESE ACCORDING TO YOUR SETUP ######
####################################################

#GCP account info
export ACCOUNT_ID=fersanchez@google.com					#your GCP account ID
#
export TF_VAR_org_id=433637338589						#your GCP org ID
export TF_VAR_billing_account=00183D-07EE2D-3060A0		#billing account for your project

#project info
export TF_VAR_project=fersanchez-0-2 #***PRE_CREATED*** project where the resources will be placed
export TF_VAR_region=us-east4
export TF_VAR_zone=us-east4-c

#master password: DELETE or COMMENT for production use
#export TF_VAR_master_password="12345678901234567890"

############ NO NEED TO CONFIGURE THESE ###############
#######################################################
export ADMIN_SVC_ACCOUNT=terraform-admin-svc-acct		#service account used by Terraform - NO SPACES
export TF_VAR_CREDS=~/.ssh/${ADMIN_SVC_ACCOUNT}.json	#location of the credentials file

export TF_VAR_bucket_name=${TF_VAR_project}"-terraform"
export GOOGLE_APPLICATION_CREDENTIALS=${TF_VAR_CREDS}
export GOOGLE_PROJECT=${TF_VAR_project}
#network and security
export TF_VAR_network=${TF_VAR_project}"-net"			#name of a network to be created
export TF_VAR_subnetwork=${TF_VAR_project}"-subnet"		#name of a subnet to be created
export TF_VAR_subnetcidr="10.10.10.0/24"				#addressing for the subnet
export TF_VAR_tag=${TF_VAR_project}"-tag"               #used to group instances and open firewall to them

#Storage - NFS server or other shared filesystem
export TF_VAR_raw_disk_name=${TF_VAR_project}"-disk"
export TF_VAR_raw_disk_size="400GB"
export TF_VAR_raw_disk_type="pd-standard"
export TF_VAR_nfs_machine_type="f1-micro"

export TF_VAR_disk=${TF_VAR_project}"-raw-disk"               			#a disk that will be created from snapshot
export TF_VAR_export_path="/var/nfsroot"
export TF_VAR_vol_1="drupal-vol"
export TF_VAR_vol_1_size="200Gi"
export TF_VAR_vol_2="apache-vol"
export TF_VAR_vol_2_size="200Gi"
export TF_VAR_device_name="sdb"

#service account to use for CloudSQL proxy
export TF_VAR_cloudsql_service_account_name="cloudsql-svc-acct"
export TF_VAR_cloudsql_service_account_description="Service account for CloudSQL proxy"
export TF_VAR_cloudsql_client_role="roles/cloudsql.client"
export TF_VAR_create_keys_role="roles/iam.serviceAccountKeyAdmin"

#cloudSQL
export TF_VAR_cloudsql_instance=$TF_VAR_project"-sql"
export TF_VAR_cloudsql_username="cloudsqlproxy"
export TF_VAR_cloudsql_tier="db-n1-standard-1"
export TF_VAR_cloudsql_storage_type="SSD"
export TF_VAR_cloudsql_db_version="MYSQL_5_7"
export TF_VAR_cloudsql_db_creds_path="~/.ssh/cloudsql-tf-creds.json"

#GKE cluster details
export TF_VAR_gke_cluster_name=$TF_VAR_project"-gke"
export TF_VAR_gke_cluster_version="1.8.8-gke.0"
export TF_VAR_gke_machine_type="n1-standard-2"
export TF_VAR_gke_cluster_size="3"
export TF_VAR_gke_username="client"

#GKE service
export TF_VAR_gke_service_name=$TF_VAR_project"-drupal-svc"
export TF_VAR_gke_app_name=$TF_VAR_project"-drupal-app"
export TF_VAR_gke_drupal_image="bitnami/drupal:8.3.7-r0"
export TF_VAR_drupal_username="user"
export TF_VAR_drupal_email="user@example.com"
export TF_VAR_drupal_password=$TF_VAR_master_password
export TF_VAR_gke_cloudsql_image="gcr.io/cloudsql-docker/gce-proxy:1.09"

export TF_VAR_gke_vol_1_name="drupal-data"
export TF_VAR_gke_vol_1_mount_path="/bitnami/drupal"
export TF_VAR_gke_vol_2_name="apache-data"
export TF_VAR_gke_vol_2_mount_path="/bitnami/apache"

#networking
export TF_VAR_ext_ip_name=$TF_VAR_project"-ext-ip"
export TF_VAR_domain="groundcontrol.me"
export TF_VAR_dns_zone_name="blog"
export TF_VAR_dns_name=$TF_VAR_dns_zone_name"."$TF_VAR_domain


#ECFS - Elastifile
export TF_VAR_NUM_OF_VMS="3"
export TF_VAR_DISKTYPE="local"
export TF_VAR_NUM_OF_DISKS="1"
export TF_VAR_CLUSTER_NAME=${TF_VAR_project}"-ecfs"
export TF_VAR_ZONE=${TF_VAR_zone}
export TF_VAR_PROJECT=${TF_VAR_project}
export TF_VAR_IMAGE="emanage-2-5-1-10-142ee106f93b"
export TF_VAR_CREDENTIALS=${TF_VAR_CREDS} 
export TF_VAR_SERVICE_EMAIL=${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}".iam.gserviceaccount.com"
