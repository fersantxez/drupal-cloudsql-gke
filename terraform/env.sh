#master password: DELETE or COMMENT for use
export TF_VAR_master_password="12345678901234567890"
#project and account info
export TF_VAR_org_id=805845699844
export TF_VAR_billing_account=00183D-07EE2D-3060A0
export TF_ADMIN=groundcontrol-terraform-admin
export TF_CREDS=~/.ssh/groundcontrol-terraform-admin.json
export TF_VAR_project=groundcontrol-www
export TF_VAR_region=us-east4
export TF_VAR_zone=us-east4-c
export TF_VAR_num_instances=3                   #to use in instance group

export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_VAR_project}

#network and security
export TF_VAR_network="groundcontrol-frontend-us-east4"
export TF_VAR_subnetwork="groundcontrol-frontend-us-east4"
export TF_VAR_tag="cloudlamp"                        #used to group instances and open firewall to them

#Storage - NFS server or other shared filesystem
export TF_VAR_snapshot="ext4-200g-us-east4-empty"     #a pre-created empty ext4 snapshot
export TF_VAR_disk="nfs-disk"               #a disk that will be created from snapshot
export TF_VAR_export_path="/var/nfsroot"
export TF_VAR_vol_1="drupal-vol"
export TF_VAR_vol_1_size="200Gi"
export TF_VAR_vol_2="apache-vol"
export TF_VAR_vol_2_size="200Gi"
export TF_VAR_device_name="sdb"


#service account to use for CloudSQL proxy
export TF_VAR_cloudsql_service_account_name="cloudsqlsa"
export TF_VAR_cloudsql_service_account_description="Service account for CloudSQL proxy"
export TF_VAR_cloudsql_client_role="roles/editor"  #"roles/cloudsql.client" #
export TF_VAR_create_keys_role="roles/iam.serviceAccountKeyAdmin"
##export SERVICE_ACCOUNT_KEY_PATH=${CREDS_LOCATION}${PROJECT_NAME}"-cloudsql-svc-acct-key.json"

#cloudSQL
export TF_VAR_cloudsql_instance=$TF_VAR_project"-sql"10
export TF_VAR_cloudsql_username="root"
export TF_VAR_cloudsql_tier="db-n1-standard-1"
export TF_VAR_cloudsql_storage_type="SSD"
export TF_VAR_cloudsql_db_version="MYSQL_5_7"
export TF_VAR_cloudsql_db_creds_path="~/.ssh/cloudsql-tf-creds.json"

#GKE cluster details
export TF_VAR_gke_cluster_name=$TF_VAR_project"-gke"
export TF_VAR_gke_cluster_version="1.8.8-gke.0"
export TF_VAR_gke_machine_type="n1-standard-1"
export TF_VAR_gke_cluster_size="3"
export TF_VAR_gke_username="client"

#GKE service
export TF_VAR_gke_service_name=$TF_VAR_PROJECT"drupal-svc"
export TF_VAR_gke_app_name=$TF_VAR_PROJECT"drupal-app"
export TF_VAR_gke_drupal_image="bitnami/drupal:8.3.7-r0"
export TF_VAR_drupal_username="user"
export TF_VAR_drupal_email="user@example.com"
export TF_VAR_drupal_password=$TF_VAR_master_password
export TF_VAR_gke_cloudsql_image="gcr.io/cloudsql-docker/gce-proxy:1.09"
#export TF_VAR_gke_cloudsql_command=() \
#    "/cloud_sql_proxy" \
#    "--dir=/cloudsql" \
#    "-instances=__INSTANCE_CONNECTION_NAME__=tcp:3306" \
#    "-credential_file=/secrets/cloudsql/credentials.json" \
#    )

export TF_VAR_gke_vol_1_name="drupal-data"
export TF_VAR_gke_vol_1_mount_path="/bitnami/drupal"
export TF_VAR_gke_vol_2_name="apache-data"
export TF_VAR_gke_vol_2_mount_path="/bitnami/apache"