# BBBY demo for Drupal + CloudSQL
# create cloudSQL proxy connection on existing instance, link GKE cluster and launch Drupal on it

#get user variables
source ./env.sh

#Enable Cloud SQL admin API -- in case this project does not have it enabled yet
open https://pantheon.corp.google.com/apis/library/sqladmin.googleapis.com/?project=$PROJECT_NAME&debugUI=DEVELOPERS

#create a SQL PROXY USER ACCOUNT
gcloud sql users create $PROXY_USER cloudsqlproxy~% --instance=$CLOUDSQL_INSTANCE && \
gcloud sql instances list && \
gcloud sql users list -i $CLOUDSQL_INSTANCE

#find out instance connection name
## can not assume this, need to find through gcloud
## export INSTANCE_CONNECTION_NAME=$PROJECT_NAME:$CLOUDSQL_REGION:$CLOUDSQL_INSTANCE
export INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $CLOUDSQL_INSTANCE | grep 'connectionName' | awk {'print $2'})
echo "**DEBUG: CloudSQL Instance name detected as: "$INSTANCE_CONNECTION_NAME

#create kubectl SECRETS for instance and DB
kubectl create secret generic cloudsql-instance-credentials \
                    --from-file="credentials.json"=$PROXY_KEY_FILE_PATH && \
kubectl create secret generic cloudsql-db-credentials \
					--from-literal=username=$CLOUDSQL_USERNAME \
					--from-literal=password=$CLOUDSQL_PASSWORD && \
kubectl get secrets

#create Storage Class from template
rm -f $STORAGECLASS_FILE
cp $STORAGECLASS_TEMPLATE_FILE $STORAGECLASS_FILE
#TODO: swap out values in storageClass template file according to env variables
#sed -i '' "s,__VARIABLE__,$VARIABLE,g" $STORAGECLASS_FILE
kubectl create -f $STORAGECLASS_FILE

#create statefulSet from template
rm -f $STATEFULSET_FILE
cp $STATEFULSET_TEMPLATE_FILE $STATEFULSET_FILE
sed -i '' "s,__INSTANCE_CONNECTION_NAME__,$INSTANCE_CONNECTION_NAME,g" $STATEFULSET_FILE
sed -i '' "s,__SERVICE_NAME__,$SERVICE_NAME,g" $STATEFULSET_FILE


#create persistent volumes or claims and add to StatefulSet (or deployment)
#swap out in template for name of service
for (( i=1; i<=$GKE_VOLUME_QTY; i++ )); do
	#create persistent volumes for drupal and apache

	#trick to substitute to variable names
	VOLUME="GKE_VOLUME_"$i
	VOLUME=$(printf '%s\n' "${!VOLUME}")
	SIZE="GKE_VOLUME_SIZE_"$i
	SIZE=$(printf '%s\n' "${!SIZE}")
	VOLUME=$VOLUME"-vol"

	#variable indirection
	echo "**DEBUG: variables will be used as: "$VOLUME" and "$SIZE

	#add Volumes (automatically created from storageClass) to statefulSet
	#swap out values in statefulSet template file according to env variables
	volume_temp="__GKE_VOLUME_"$i"__"
	volume_size_temp="__GKE_VOLUME_SIZE_"$i"__"
	sed -i '' "s,$volume_temp,$VOLUME,g" $STATEFULSET_FILE
	sed -i '' "s,$volume_size_temp,$SIZE"i",g" $STATEFULSET_FILE

done


#launch the statefulSet from file 
kubectl create -f $STATEFULSET_FILE && \
kubectl get statefulset 

#expose the deployment
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
