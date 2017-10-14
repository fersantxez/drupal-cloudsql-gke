#GCP project details
export PROJECT_NAME="fersanchez-drupal-cloudsql"
export REGION="us-east1"
export ZONE="us-east1-b"
export SOURCE_SNAPSHOT="snap-blank-ext4-50g-us-east1-b"

#this project details
export HOME_DIR="../"
export CREDS_LOCATION=$HOME"/.ssh/cloudsql-credentials/"
export SCRIPTS_LOCATION=$HOME_DIR"scripts/"
export TEMPLATES_LOCATION=$HOME_DIR"templates/"
export YAML_RUN_LOCATION=$HOME_DIR"yaml_run/"

#GKE cluster details
export GKE_CLUSTER_NAME="fersanchez-bbby-gke-6"
export GKE_CLUSTER_VERSION="1.7.6-gke.1"
export GKE_MACHINE_TYPE="n1-standard-1"
export GKE_CLUSTER_SIZE="5"
export GKE_SECONDARY_ZONE="" #for multi-zone HA

#Cloud SQL parameters
export CLOUDSQL_INSTANCE="drupal-sql6"
export CLOUDSQL_USERNAME="root"
export CLOUDSQL_TIER="db-n1-standard-1 "
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

## KUBERNETES FILES
#service name
export SERVICE_NAME="bbby-cms" #LOWERCASE ONLY FOR VOLUME/DISK NAMES
export SERVICE_PORT_HTTP="80"
export SERVICE_PORT_HTTPS="443"
export SERVICE_TEMPLATE_FILE=$TEMPLATES_LOCATION"service.yaml"
export SERVICE_FILE=$YAML_RUN_LOCATION"service.yaml"
#k8s deployment template and file
#export DEPLOYMENT_TEMPLATE_FILE=$TEMPLATES_LOCATION"deployment_claimVolume.yaml"
export DEPLOYMENT_TEMPLATE_FILE=$TEMPLATES_LOCATION"deployment_nfs.yaml"
export DEPLOYMENT_FILE=$YAML_RUN_LOCATION"deployment.yaml"
#k8s ingress template and file
export INGRESS_TEMPLATE_FILE=$TEMPLATES_LOCATION"ingress.yaml"
export INGRESS_FILE=$YAML_RUN_LOCATION"ingress.yaml"
#k8s persistent volumes
export GKE_VOLUME_QTY=2
#export GKE_VOLUME_1=#$SERVICE_NAME"-drupal"
export GKE_VOLUME_1="/var/nfsroot/drupal"
export GKE_VOLUME_SIZE_1="50G"
#export GKE_VOLUME_2=$SERVICE_NAME"-apache"
export GKE_VOLUME_2="/var/nfsroot/apache"
export GKE_VOLUME_SIZE_2="50G"
export PV_TEMPLATE_FILE=$TEMPLATES_LOCATION"pv_nfs.yaml"
export PV_FILE=$YAML_RUN_LOCATION"pv.yaml"
#export PVC_TEMPLATE_FILE=$TEMPLATES_LOCATION"pvc.yaml"
export PVC_TEMPLATE_FILE=$TEMPLATES_LOCATION"pvc_nfs.yaml" #for statefulSet with dynamic unnamed volumes
export PVC_FILE=$YAML_RUN_LOCATION"pvc.yaml"
#export STORAGECLASS_TEMPLATE_FILE=$TEMPLATES_LOCATION"storageClass.yaml"
export STORAGECLASS_TEMPLATE_FILE=$TEMPLATES_LOCATION"storageClass_nfs.yaml"
export STORAGECLASS_FILE=$YAML_RUN_LOCATION"storageClass.yaml"
#k8s statefulset parameters
export STATEFULSET_TEMPLATE_FILE=$TEMPLATES_LOCATION"statefulset_nfs.yaml"
export STATEFULSET_FILE=$YAML_RUN_LOCATION"statefulSet.yaml"
export GKE_STATEFULSET_NAME=$SERVICE_NAME"-statefulset"

#DEPLYMENT MANAGER SECTION - For the NFS server
export NFS_DEPLOYMENT_NAME="nfs-deployment"
export NFS_TEMPLATE_FILE="nfs-server.yaml"
export NFS_SERVER="nfs-server" #name or IP address. On GCP it's accessible by name




