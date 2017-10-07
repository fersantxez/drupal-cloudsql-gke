#Create GKE cluster

source ./env.sh

#create container cluster 

# gcloud container clusters create NAME [--additional-zones=ZONE,[ZONE,…]] [--async] [--cluster-ipv4-cidr=CLUSTER_IPV4_CIDR] 
# [--cluster-version=CLUSTER_VERSION] [--disable-addons=[DISABLE_ADDON,…]] [--disk-size=DISK_SIZE] [--enable-autoupgrade] 
# [--no-enable-cloud-endpoints] [--no-enable-cloud-logging] [--no-enable-cloud-monitoring] [--image-type=IMAGE_TYPE] 
# [--machine-type=MACHINE_TYPE, -m MACHINE_TYPE] [--max-nodes-per-pool=MAX_NODES_PER_POOL] [--network=NETWORK] 
# [--node-labels=[NODE_LABEL,…]] [--num-nodes=NUM_NODES; default=3] [--password=PASSWORD] [--scopes=SCOPE,[SCOPE,…]] 
# [--subnetwork=SUBNETWORK] [--tags=TAG,[TAG,…]] [--username=USERNAME, -u USERNAME; default="admin"] [--zone=ZONE, -z ZONE] [GCLOUD_WIDE_FLAG …]

gcloud container clusters create $GKE_CLUSTER_NAME \
--zone=$ZONE \
--cluster-version=$GKE_CLUSTER_VERSION \
--num-nodes=$GKE_CLUSTER_SIZE \
--machine-type=$GKE_MACHINE_TYPE \
&& gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $ZONE \
&& kubectl get nodes
