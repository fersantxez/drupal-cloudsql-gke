#project and account info
export TF_VAR_name="test-fer"
export TF_VAR_org_id=433637338589
export TF_VAR_billing_account=00183D-07EE2D-3060A0
export TF_ADMIN=cloudlamp-terraform-admin
export TF_CREDS=~/.ssh/terraform-admin.json
export TF_PROJECT=cloudlamp-org
export TF_VAR_project_name=$TF_PROJECT
export TF_VAR_region=us-east4
export TF_VAR_zone=us-east4-c
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_PROJECT}

#instance group with load balancer etc. - TEST
export TF_VAR_num_instances=3                   #to use in instance group
export TF_VAR_network="default"
export TF_VAR_tag="web"                        #used to group instances and open firewall to them

#NFS server
export TF_VAR_nfs_export_path="/var/nfsroot"
export TF_VAR_nfs_vol_1="drupal"
export TF_VAR_nfs_vol_2="apache"
export TF_VAR_nfs_disk="/dev/sdb"
export TF_VAR_blank_volume="" #a blank formatted volume to put the NFS data on

#service account to use for CloudSQL proxy
export TF_SERVICE_ACCOUNT_NAME="cloudsql-svc-acct"
export TF_SERVICE_ACCOUNT_DESCRIPTION="Service account for CloudSQL proxy"
export TF_SERVICE_ACCOUNT_ROLE="roles/cloudsql.client"
##export SERVICE_ACCOUNT_KEY_PATH=${CREDS_LOCATION}${PROJECT_NAME}"-cloudsql-svc-acct-key.json"

#cloudSQL
export TF_CLOUDSQL_INSTANCE="groundcontrol-sql"
export TF_CLOUDSQL_USERNAME="root"
export TF_CLOUDSQL_TIER="db-n1-standard-1"
export TF_CLOUDSQL_STORAGE_TYPE="SSD"
export TF_CLOUDSQL_DB_VERSION="MYSQL_5_7"