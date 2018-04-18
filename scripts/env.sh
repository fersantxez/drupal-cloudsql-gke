#GCP project details
export PROJECT_NAME="groundcontrol-www"
export REGION="us-east4"
export ZONE="us-east4-c"
export SOURCE_SNAPSHOT="snap-blank-ext4-50g-us-east4-c"

#NFS server details - THIS HAS TO BE CREATED OUTSIDE OF THE SCRIPT/PROCESS
export NFS_SERVER="10.0.2.100" #IP address
export NFS_PATH="/var/nfsroot" #each share
#empty disk image
export DISK_IMAGE_SIZE="200GB"
export DISK_NAME="empty-disk"
export DISK_IMAGE_NAME="empty-disk-image"

#Service name - this will be used to expose the service outside of GCP
export SERVICE_NAME="groundcontrol-cms" #LOWERCASE ONLY FOR VOLUME/DISK NAMES
export SERVICE_PORT_HTTP="80"
export SERVICE_PORT_HTTPS="443"
#purely internal:
export SERVICE_TEMPLATE_FILE=$TEMPLATES_LOCATION"service.yaml"
export SERVICE_FILE=$YAML_RUN_LOCATION"service.yaml"

#this project's details
export HOME_DIR="../"
export CREDS_LOCATION=$HOME"/.ssh/cloudsql-credentials/"
export SCRIPTS_LOCATION=$HOME_DIR"scripts/"
export TEMPLATES_LOCATION=$HOME_DIR"templates/"
export YAML_RUN_LOCATION=$HOME_DIR"yaml_run/"

#GKE cluster details
export GKE_CLUSTER_NAME="groundcontrol-frontend-cluster"
export GKE_CLUSTER_VERSION="1.8.8-gke.0"
export GKE_MACHINE_TYPE="n1-standard-1"
export GKE_CLUSTER_SIZE="3"
export GKE_SECONDARY_ZONE="" #for multi-zone HA

#Cloud SQL parameters
export CLOUDSQL_INSTANCE="groundcontrol-sql"
export CLOUDSQL_USERNAME="root"
export CLOUDSQL_TIER="db-n1-standard-1"
export CLOUDSQL_STORAGE_TYPE="SSD"
export CLOUDSQL_DB_VERSION="MYSQL_5_7"
export CLOUDSQL_BACKUP_START_TIME="09:00"
#service account to use for CloudSQL proxy
export SERVICE_ACCOUNT_NAME="cloudsql-svc-acct"
export SERVICE_ACCOUNT_DESCRIPTION="Service account for CloudSQL proxy"
export SERVICE_ACCOUNT_ROLE="roles/cloudsql.client"
export SERVICE_ACCOUNT_KEY_PATH=${CREDS_LOCATION}${PROJECT_NAME}"-cloudsql-svc-acct-key.json"
#CloudSQL Proxy parameters
export CLOUDSQL_PROXY_USER="proxyuser"
#When using Unix socket files for connecting client and proxy, dedicated directory for the UNIX socket file
export CLOUDSQL_DIR=$HOME_DIR"cloudsql"
#When using TCP sockets, which port to use
export CLOUDSQL_PORT="3306"
#where to store the cloudsql proxy binary upon downloading it
export CLOUDSQL_BIN="/usr/local/bin/cloud_sql_proxy"

## KUBERNETES
#k8s deployment template and file
export DEPLOYMENT_TEMPLATE_FILE=$TEMPLATES_LOCATION"deployment_nfs.yaml"
export DEPLOYMENT_FILE=$YAML_RUN_LOCATION"deployment.yaml"
#k8s storageclass template and file
export STORAGECLASS_TEMPLATE_FILE=$TEMPLATES_LOCATION"storageclass.yaml"
export STORAGECLASS_FILE=$YAML_RUN_LOCATION"storageclass.yaml"
#k8s ingress template and file
export INGRESS_TEMPLATE_FILE=$TEMPLATES_LOCATION"ingress.yaml"
export INGRESS_FILE=$YAML_RUN_LOCATION"ingress.yaml"

#k8s persistent volumes
export GKE_VOLUME_QTY=2
export GKE_VOLUME_1="/var/nfsroot/drupal"
export GKE_VOLUME_SIZE_1="200G"
export GKE_VOLUME_2="/var/nfsroot/apache"
export GKE_VOLUME_SIZE_2="200G"
export PV_TEMPLATE_FILE=$TEMPLATES_LOCATION"pv_nfs.yaml"
export PV_FILE=$YAML_RUN_LOCATION"pv.yaml"
export PVC_TEMPLATE_FILE=$TEMPLATES_LOCATION"pvc_nfs.yaml" #for statefulSet with dynamic unnamed volumes
export PVC_FILE=$YAML_RUN_LOCATION"pvc.yaml"




