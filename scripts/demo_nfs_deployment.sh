# BBBY demo for Drupal + CloudSQL
# create cloudSQL proxy connection on existing instance, link GKE cluster and launch Drupal on it

#get user variables
source ./env.sh

#Enable Cloud SQL admin API -- in case this project does not have it enabled yet
open https://pantheon.corp.google.com/apis/library/sqladmin.googleapis.com/?project=$PROJECT_NAME&debugUI=DEVELOPERS

#create a service account to be used by CloudSQL
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
	--display-name "$SERVICE_ACCOUNT_DESCRIPTION"
#enable the service account to access CloudSQL
export SERVICE_ACCOUNT_EMAIL=${SERVICE_ACCOUNT_NAME}@${PROJECT_NAME}.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding $PROJECT_NAME \
    --member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role $SERVICE_ACCOUNT_ROLE
#generate credential for CloudSQL proxy
mkdir -p $CREDS_LOCATION #store credentials in safe space
gcloud iam service-accounts keys create $SERVICE_ACCOUNT_KEY_PATH \
	--iam-account=$SERVICE_ACCOUNT_EMAIL \
	--key-file-type="json"

#create a SQL PROXY USER ACCOUNT
gcloud sql users create $CLOUDSQL_PROXY_USER cloudsqlproxy~% --instance=$CLOUDSQL_INSTANCE && \
gcloud sql instances list && \
gcloud sql users list -i $CLOUDSQL_INSTANCE

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
                    --from-file="credentials.json"=$PROXY_KEY_FILE_PATH && \
kubectl create secret generic cloudsql-db-credentials \
					--from-literal=username=$CLOUDSQL_USERNAME \
					--from-literal=password=$CLOUDSQL_PASSWORD && \
kubectl get secrets

#create NFS server - use deployment manager - TODO: launch from CLI
#gcloud deployment-manager deployments create $NFS_DEPLOYMENT_NAME \
#    --config $NFS_TEMPLATE_FILE
#gcloud deployment-manager deployments describe $NFS_DEPLOYMENT_NAME


#create deployment from template
rm -f $DEPLOYMENT_FILE
cp $DEPLOYMENT_TEMPLATE_FILE $DEPLOYMENT_FILE
sed -i '' "s,__INSTANCE_CONNECTION_NAME__,$INSTANCE_CONNECTION_NAME,g" $DEPLOYMENT_FILE
sed -i '' "s,__SERVICE_NAME__,$SERVICE_NAME,g" $DEPLOYMENT_FILE

#create Storage Class from template
rm -f $STORAGECLASS_FILE
cp $STORAGECLASS_TEMPLATE_FILE $STORAGECLASS_FILE
#swap out values in DEPLOYMENT template file according to env variables
#sed -i '' "s,__INSTANCE_CONNECTION_NAME__,$INSTANCE_CONNECTION_NAME,g" $DEPLOYMENT_FILE
kubectl create -f $STORAGECLASS_FILE

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
	#VOLUME=$VOLUME"-vol" #remove the "-vol" so that it matches the NFS path
 
	#variable indirection
	echo "**DEBUG: variables will be used as: "$VOLUME", "$DISK" and "$SIZE

	#CREATE DISK - add the "B" as gcloud is "GB" but k8s is "Gi"
	#TODO: create volumes and exports in NFS server
	#need to use a volume name without "/", but need the path with it
	NFS_PATH=${VOLUME}
	VOLUME=$(echo $VOLUME | tr / 0) #swap out / for 0

	#CREATE PERSISTENT VOLUME
	#PV_FILE=$YAML_RUN_LOCATION$VOLUME"-"$(basename $PV_TEMPLATE_FILE)
	echo "**DEBUG: PV_TEMPLATE_FILE will be: "$PV_TEMPLATE_FILE", PV_FILE will be: "$PV_FILE
	rm -f $PV_FILE
	cp $PV_TEMPLATE_FILE $PV_FILE
	#swap out values in PV file file according to env variables
	sed -i '' "s,__VOLUME_NAME__,$VOLUME,g" $PV_FILE
	sed -i '' "s,__VOLUME_SIZE__,$SIZE"i",g" $PV_FILE
	sed -i '' "s,__NFS_SERVER__,$NFS_SERVER,g" $PV_FILE
	sed -i '' "s,__NFS_PATH__,$NFS_PATH,g" $PV_FILE

	#create persistent volume claim in k8s
	kubectl create -f $PV_FILE
	kubectl get pv

	#CREATE PERSISTENT VOLUME CLAIM
	CLAIM=$VOLUME"-claim"
	#PVC_FILE=$YAML_RUN_LOCATION$VOLUME"-"$(basename $PVC_TEMPLATE_FILE)
	echo "**DEBUG: PVC_TEMPLATE_FILE will be: "$PVC_TEMPLATE_FILE", PVC_FILE will be: "$PVC_FILE
	rm -f $PVC_FILE
	cp $PVC_TEMPLATE_FILE $PVC_FILE
	#swap out values in PV file file according to env variables
	sed -i '' "s,__CLAIM_NAME__,$CLAIM,g" $PVC_FILE
	sed -i '' "s,__VOLUME_SIZE__,$SIZE"i",g" $PVC_FILE
	sed -i '' "s,__VOLUME_NAME__,$VOLUME,g" $PVC_FILE	
	#create persistent volume claim in k8s
	kubectl create -f $PVC_FILE
	kubectl get pvc

	#add CLAIM to deployment -- (for fully controlled cycle across DISK-PV-PVC-CLAIM - valid outside of GCP with on-prem storage)
	claim_temp="__PV_CLAIM_"$i"__"
	sed -i '' "s,$claim_temp,$CLAIM,g" $DEPLOYMENT_FILE
	
done

#launch the deployment from file 
kubectl create -f $DEPLOYMENT_FILE && \
kubectl get deployments 

#expose the deployment - either from kubectl:
#kubectl expose deployment $SERVICE_NAME --target-port=$SERVICE_PORT_HTTP --type=NodePort
#... or using a service file:
rm -f $SERVICE_FILE
cp $SERVICE_TEMPLATE_FILE $SERVICE_FILE
#swap out values in DEPLOYMENT template file according to env variables
sed -i '' "s,__SERVICE_NAME__,$SERVICE_NAME,g" $SERVICE_FILE
sed -i '' "s,__SERVICE_PORT_HTTP__,$SERVICE_PORT_HTTP,g" $SERVICE_FILE
sed -i '' "s,__SERVICE_PORT_HTTPS__,$SERVICE_PORT_HTTPS,g" $SERVICE_FILE

kubectl create -f $SERVICE_FILE
kubectl get services 

#create INGRESS file from template
rm -f $INGRESS_FILE
cp $INGRESS_TEMPLATE_FILE $INGRESS_FILE
#swap out values in INGRESS template
sed -i '' "s,__SERVICE_NAME__,$SERVICE_NAME,g" $INGRESS_FILE
sed -i '' "s,__SERVICE_PORT_HTTP__,$SERVICE_PORT_HTTP,g" $INGRESS_FILE
sed -i '' "s,__SERVICE_PORT_HTTPS__,$SERVICE_PORT_HTTPS,g" $INGRESS_FILE
#create the ingress
kubectl apply -f $INGRESS_FILE
kubectl get ingress

###
### REFERENCE
###
#For Cloud SQL proxy as docker container: 
#from kayun this is the command I used in a customer demo a few months ago on the proxy.  in this case I ran docker locally as the proxy:
#docker run -d -v /mnt/cloudsql:/cloudsql -v /Users/kayunlam/Code/default/sql/kyl-cloud-demo-sql-client-service-account.json:/config -p 127.0.0.1:3306:3306 gcr.io/cloudsql-docker/gce-proxy:1.09 /cloud_sql_proxy -instances=kyl-cloud-demo-project:us-east4:demo-mysql=tcp:0.0.0.0:3306 -credential_file=/config