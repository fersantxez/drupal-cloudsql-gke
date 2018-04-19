#master password: DELETE or COMMENT for use
export TF_VAR_master_password="12345678901234567890"
#project and account info
#export TF_VAR_name="test-fer"
export TF_VAR_org_id=805845699844
export TF_VAR_billing_account=00183D-07EE2D-3060A0
export TF_ADMIN=groundcontrol-terraform-admin
export TF_CREDS=~/.ssh/groundcontrol-terraform-admin.json
export TF_VAR_project=groundcontrol-www
export TF_VAR_region=us-east4
export TF_VAR_zone=us-east4-c

export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_VAR_project}

#instance group with load balancer etc. - TEST
export TF_VAR_num_instances=3                   #to use in instance group
export TF_VAR_network="groundcontrol-frontend-us-east4"
export TF_VAR_tag="web"                        #used to group instances and open firewall to them

#NFS server
export TF_VAR_nfs_snapshot="ext4-200g-us-east4-empty"     #a pre-created empty ext4 snapshot
export TF_VAR_nfs_disk="nfs-disk"               #a disk that will be created from snapshot
export TF_VAR_nfs_export_path="/var/nfsroot"
export TF_VAR_nfs_vol_1="drupal"
export TF_VAR_nfs_vol_2="apache"
export TF_VAR_nfs_device_name="sdb"

#service account to use for CloudSQL proxy
export TF_VAR_cloudsql_service_account_name="cloudsql-svc-acct"
export TF_VAR_cloudsql_service_account_description="Service account for CloudSQL proxy"
export TF_VAR_cloudsql_service_account_role="roles/cloudsql.client"
##export SERVICE_ACCOUNT_KEY_PATH=${CREDS_LOCATION}${PROJECT_NAME}"-cloudsql-svc-acct-key.json"

#cloudSQL
export TF_VAR_cloudsql_instance=$TF_VARVAR_project"-sql"
export TF_VAR_cloudsql_username="root"
export TF_VAR_cloudsql_tier="db-n1-standard-1"
export TF_VAR_cloudsql_storage_type="SSD"
export TF_VAR_cloudsql_db_version="MYSQL_5_7"

#GKE cluster details
export TF_VAR_gke_cluster_name=$TF_VAR_project"-gke"
export TF_VAR_gke_cluster_version="1.8.8-gke.0"
export TF_VAR_gke_machine_type="n1-standard-1"
export TF_VAR_gke_cluster_size="3"
export TF_VAR_gke_username="client"

