# BBBY demo for Drupal + CloudSQL
# create cloudSQL proxy connection on existing instance, link GKE cluster and launch Drupal on it

#get user variables
source ./env.sh

#Enable Cloud SQL admin API -- in case this project does not have it enabled yet
open https://pantheon.corp.google.com/apis/library/sqladmin.googleapis.com/?project=$PROJECT_NAME&debugUI=DEVELOPERS

#create a SQL PROXY USER ACCOUNT
gcloud sql users create $PROXY_USER cloudsqlproxy~% --instance=$CLOUDSQL_INSTANCE

#find out instance connection name
## can not assume this, need to find through gcloud
## export INSTANCE_CONNECTION_NAME=$PROJECT_NAME:$CLOUDSQL_REGION:$CLOUDSQL_INSTANCE
export INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $CLOUDSQL_INSTANCE | grep 'connectionName' | awk {'print $2'})
echo "**DEBUG: CloudSQL Instance name detected as: "$INSTANCE_CONNECTION_NAME

#get kubectl credentials for terminal where this is running (laptop or remote VM/shell) so that kubectl works
#this is done in gke.sh
#gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $ZONE

#create kubectl SECRETS for instance and DB
kubectl create secret generic cloudsql-instance-credentials \
                    --from-file="credentials.json"=$PROXY_KEY_FILE_PATH
kubectl create secret generic cloudsql-db-credentials \
					--from-literal=username=$CLOUDSQL_USERNAME \
					--from-literal=password=$CLOUDSQL_PASSWORD

######
###### TEST CLOUDSQL PROXY ON LOCAL LAPTOP
######

#set local gcp application default credentials
#gcloud auth application-default login --launch-browser

#download cloudSQL proxy
#linux
#sudo curl -o $CLOUDSQL_BIN https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 && sudo chmod +x $CLOUDSQL_BIN
#osx
#sudo curl -o $CLOUDSQL_BIN https://dl.google.com/cloudsql/cloud_sql_proxy.darwin.amd64 && sudo chmod +x $CLOUDSQL_BIN

#launch cloud-sql-proxy FROM LOCAL LAPTOP:

#with UNIX SOCKETS and local credentials file
#create dedicated dir for unix socket file
#mkdir -p $CLOUDSQL_DIR
#killall $(basename $CLOUDSQL_BIN)
#$CLOUDSQL_BIN \
#-dir=$CLOUDSQL_DIR \
#-instances=$INSTANCE_CONNECTION_NAME \
#-credential_file=$PROXY_KEY_FILE_PATH & \
#mysql -u $CLOUDSQL_USERNAME -p -S $CLOUDSQL_DIR:$$INSTANCE_CONNECTION_NAME

#with UNIX SOCKETS default credentials from SDK
#create dedicated dir for unix socket file
#mkdir -p $CLOUDSQL_DIR
#killall $(basename $CLOUDSQL_BIN)
#$CLOUDSQL_BIN \
#-dir=$CLOUDSQL_DIR \
#-instances=$INSTANCE_CONNECTION_NAME & \
#launch the client against the local socket
#mysql -u $CLOUDSQL_USERNAME -p -S $CLOUDSQL_DIR:$$INSTANCE_CONNECTION_NAME

#with TCP SOCKETS on port 3306 and local credentials file
#killall $(basename $CLOUDSQL_BIN)
#$CLOUDSQL_BIN \
#-instances=$INSTANCE_CONNECTION_NAME=tcp:3306 \
#-credential_file=$PROXY_KEY_FILE_PATH & \
#launch the client against the local proxy
#mysql -u $CLOUDSQL_USERNAME -p --host 127.0.0.1

###### RUN CLOUDSQL PROXY AS PART OF A KUBERNETES DEPLOYMENT - run as container in pod
###### check file $DEPLOYMENT_TEMPLATE_FILE for details - look for cloudsql-proxy container
######

#create persistent volumes
#swap out in template for name of service
for (( i=1; i<=$GKE_VOLUME_QTY; i++ )); do
	#create persistent volumes for drupal and apache

	#trick to substitute to variable names
	VOLUME="GKE_VOLUME_"$i
	VOLUME=$(printf '%s\n' "${!VOLUME}")
	SIZE="GKE_VOLUME_SIZE_"$i
	SIZE=$(printf '%s\n' "${!SIZE}")
	DISK=$VOLUME"-disk"
	#variable indirection
	echo "**DEBUG: variables will be used as: "$VOLUME", "$DISK" and "$SIZE

	#CREATE DISK - add the "B" as gcloud is "GB" but k8s is "Gi"
	gcloud compute disks create --size $SIZE"B" $DISK --zone=$ZONE
	#TODO:format disks and create filesystem if needed

	#CREATE PERSISTENT VOLUME
	PV_FILE=$TEMPLATES_LOCATION$VOLUME"-"$(basename $PV_TEMPLATE_FILE)
	echo "**DEBUG: PV_TEMPLATE_FILE will be: "$PV_TEMPLATE_FILE", PV_FILE will be: "$PV_FILE
	rm -f $PV_FILE
	cp $PV_TEMPLATE_FILE $PV_FILE
	#swap out values in PV file file according to env variables
	sed -i '' "s,__VOLUME_NAME__,$VOLUME,g" $PV_FILE
	sed -i '' "s,__VOLUME_SIZE__,$SIZE"i",g" $PV_FILE
	sed -i '' "s,__DISK_NAME__,$DISK,g" $PV_FILE
	#create persistent volume claim in k8s
	kubectl create -f $PV_FILE

	#CREATE PERSISTENT VOLUME CLAIM
	CLAIM=$VOLUME"-claim"
	PVC_FILE=$YAML_RUN_LOCATION$VOLUME"-"$(basename $PVC_TEMPLATE_FILE)
	echo "**DEBUG: PVC_TEMPLATE_FILE will be: "$PVC_TEMPLATE_FILE", PVC_FILE will be: "$PVC_FILE
	rm -f $PVC_FILE
	cp $PVC_TEMPLATE_FILE $PVC_FILE
	#swap out values in PV file file according to env variables
	sed -i '' "s,__CLAIM_NAME__,$CLAIM,g" $PVC_FILE
	sed -i '' "s,__VOLUME_SIZE__,$SIZE"i",g" $PVC_FILE
	#create persistent volume claim in k8s
	kubectl create -f $PVC_FILE


done

#create deployment from template
rm -f $DEPLOYMENT_FILE
cp $DEPLOYMENT_TEMPLATE_FILE $DEPLOYMENT_FILE
#swap out values in DEPLOYMENT template file according to env variables
sed -i '' "s,__INSTANCE_CONNECTION_NAME__,$INSTANCE_CONNECTION_NAME,g" $DEPLOYMENT_FILE
sed -i '' "s,__SERVICE_NAME__,$SERVICE_NAME,g" $DEPLOYMENT_FILE

#launch the deployment from file 
kubectl create -f $DEPLOYMENT_FILE

#expose the deployment
kubectl expose deployment $SERVICE_NAME --target-port=$SERVICE_PORT_HTTP --type=NodePort

#create INGRESS file from template
rm -f $INGRESS_FILE
cp $INGRESS_TEMPLATE_FILE $INGRESS_FILE
#swap out values in INGRESS template
sed -i '' "s,__SERVICE_NAME__,$SERVICE_NAME,g" $INGRESS_FILE
sed -i '' "s,__SERVICE_PORT_HTTP__,$SERVICE_PORT_HTTP,g" $INGRESS_FILE
sed -i '' "s,__SERVICE_PORT_HTTPS__,$SERVICE_PORT_HTTPS,g" $INGRESS_FILE
#create the ingress
kubectl apply -f $INGRESS_FILE

###
### REFERENCE
###
#For Cloud SQL proxy as docker container: 
#from kayun this is the command I used in a customer demo a few months ago on the proxy.  in this case I ran docker locally as the proxy:
#docker run -d -v /mnt/cloudsql:/cloudsql -v /Users/kayunlam/Code/default/sql/kyl-cloud-demo-sql-client-service-account.json:/config -p 127.0.0.1:3306:3306 gcr.io/cloudsql-docker/gce-proxy:1.09 /cloud_sql_proxy -instances=kyl-cloud-demo-project:us-east4:demo-mysql=tcp:0.0.0.0:3306 -credential_file=/config