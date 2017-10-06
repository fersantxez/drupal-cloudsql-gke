# BBBY demo for Drupal + CloudSQL

#GCP project details
export PROJECT_NAME=fersanchez-drupal-cloudsql

#GKE cluster details
export GKE_CLUSTER_NAME=fersanchez-bbby-gke-1
export GKE_ZONE=us-east1-b

#Cloud SQL parameters
export CLOUDSQL_INSTANCE=drupal-sql
export CLOUDSQL_REGION=us-east1
export CLOUDSQL_USERNAME=root
echo -n "**INPUT: Enter MySQL password for user "$CLOUDSQL_USERNAME":"
read -s CLOUDSQL_PASSWORD

export PROXY_KEY_FILE_PATH=./fersanchez-drupal-cloudsql-212ef5bdd353.json
export PROXY_USER=proxyuser

#CLI tricks for local proxy
export CLOUDSQL_DIR=~/cloudsql
export CLOUDSQL_BIN=/usr/local/bin/cloud_sql_proxy

#deployment template and file
export DEPLOYMENT_TEMPLATE_FILE=./drupal_cloudsqlproxy_deployment_template.yaml
export DEPLOYMENT_FILE=./drupal_cloudsqlproxy_deployment.yaml

#get project credentials
gcloud config set project $PROJECT_NAME
#get k8s credentials 
gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $GKE_ZONE
#export PATH=$PWD/bin:$PATH

#Enable Cloud SQL admin API
open https://pantheon.corp.google.com/apis/library/sqladmin.googleapis.com/?project=$PROJECT_NAME&debugUI=DEVELOPERS

#create a SQL PROXY USER ACCOUNT
 gcloud sql users create $PROXYUSER cloudsqlproxy~% --instance=

#find out instance connection name
## can not assume this, need to find through gcloud
## export INSTANCE_CONNECTION_NAME=$PROJECT_NAME:$CLOUDSQL_REGION:$CLOUDSQL_INSTANCE
export INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $CLOUDSQL_INSTANCE | grep 'connectionName' | awk {'print $2'})
echo "**DEBUG: Instance name detected as: "$INSTANCE_CONNECTION_NAME

#create kubectl SECRETS for instance and DB
kubectl create secret generic cloudsql-instance-credentials \
                    --from-file=$PROXY_KEY_FILE_PATH
kubectl create secret generic cloudsql-db-credentials \
					--from-literal=username=$CLOUDSQL_USERNAME \
					--from-literal=password=$CLOUDSQL_PASSWORD

#SET GCP DEFAULT APPLICATION CREDENTIALS
gcloud auth application-default login --launch-browser

#download cloudSQL proxy
#linux
#sudo curl -o $CLOUDSQL_BIN https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 && sudo chmod +x $CLOUDSQL_BIN
#osx
sudo curl -o $CLOUDSQL_BIN https://dl.google.com/cloudsql/cloud_sql_proxy.darwin.amd64 && sudo chmod +x $CLOUDSQL_BIN

#launch cloud-sql-proxy FROM LOCAL LAPTOP
mkdir -p $CLOUDSQL_DIR


#with UNIX SOCKETS and local credentials file
#$CLOUDSQL_BIN \
#-dir=$CLOUDSQL_DIR \
#-instances=$INSTANCE_CONNECTION_NAME \
#-credential_file=$PROXY_KEY_FILE_PATH & \
#with UNIX SOCKETS default credentials from SDK
#$CLOUDSQL_BIN \
#-dir=$CLOUDSQL_DIR \
#-instances=$INSTANCE_CONNECTION_NAME & \
#launch the client against the local socket
#mysql -u $CLOUDSQL_USERNAME -p -S $CLOUDSQL_DIR:$$INSTANCE_CONNECTION_NAME

#with TCP SOCKETS on port 3306 and local credentials file
$CLOUDSQL_BIN \
-instances=$INSTANCE_CONNECTION_NAME=tcp:3306 \
-credential_file=$PROXY_KEY_FILE_PATH & \
#launch the client against the local proxy
mysql -u $CLOUDSQL_USERNAME -p --host 127.0.0.1


#create deployment from template
rm -f $DEPLOYMENT_FILE
cp $DEPLOYMENT_TEMPLATE_FILE $DEPLOYMENT_FILE
#SWAP OUT VALUES IN TEMPLATE
sed -i '' "s,__INSTANCE_CONNECTION_NAME__,$INSTANCE_CONNECTION_NAME,g" $DEPLOYMENT_FILE
#sed -i '' "s,__CLOUDSQL_DIR__,$CLOUDSQL_DIR,g" $DEPLOYMENT_FILE

#launch the deployment
kubectl create -f $DEPLOYMENT_FILE


###
### REFERENCE
###
#For Cloud SQL proxy as docker container: 
#from kayun this is the command I used in a customer demo a few months ago on the proxy.  in this case I ran docker locally as the proxy:
#docker run -d -v /mnt/cloudsql:/cloudsql -v /Users/kayunlam/Code/default/sql/kyl-cloud-demo-sql-client-service-account.json:/config -p 127.0.0.1:3306:3306 gcr.io/cloudsql-docker/gce-proxy:1.09 /cloud_sql_proxy -instances=kyl-cloud-demo-project:us-east4:demo-mysql=tcp:0.0.0.0:3306 -credential_file=/config