#Create GKE cluster

source ./env.sh

#create container cluster 

gcloud container clusters create $GKE_CLUSTER_NAME \
--zone=$ZONE \
--cluster-version=$GKE_CLUSTER_VERSION \
--num-nodes=$GKE_CLUSTER_SIZE \
--machine-type=$GKE_MACHINE_TYPE \
&& gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $ZONE \
&& kubectl get nodes
