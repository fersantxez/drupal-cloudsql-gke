#Create CloudSQL instance

source ./env.sh

#gcloud sql instances create INSTANCE [--activation-policy=ACTIVATION_POLICY] [--assign-ip] [--async] [--authorized-gae-apps=APP,[APP,…]]
# [--authorized-networks=NETWORK,[NETWORK,…]] [--no-backup] [--backup-start-time=BACKUP_START_TIME] [--cpu=CPU] [--database-flags=FLAG=VALUE,[FLAG=VALUE,…]]
# [--database-version=DATABASE_VERSION; default="MYSQL_5_6"] [--enable-bin-log] [--failover-replica-name=FAILOVER_REPLICA_NAME]
# [--follow-gae-app=FOLLOW_GAE_APP] 
# [--gce-zone=GCE_ZONE] [--maintenance-release-channel=MAINTENANCE_RELEASE_CHANNEL]
# [--maintenance-window-day=MAINTENANCE_WINDOW_DAY] [--maintenance-window-hour=MAINTENANCE_WINDOW_HOUR]
# [--master-instance-name=MASTER_INSTANCE_NAME] [--memory=MEMORY] [--pricing-plan=PRICING_PLAN, -p PRICING_PLAN; default="PER_USE"] 
# [--region=REGION; default="us-central"] [--replica-type=REPLICA_TYPE] [--replication=REPLICATION] [--require-ssl] 
# [--storage-auto-increase] [--storage-size=STORAGE_SIZE] [--storage-type=STORAGE_TYPE] [--tier=TIER, -t TIER] [GCLOUD_WIDE_FLAG …]

gcloud sql instances create $CLOUDSQL_INSTANCE \
--region=$REGION \
--gce-zone=$ZONE \
--database-version=$CLOUDSQL_DB_VERSION \
--storage-type=$CLOUDSQL_STORAGE_TYPE \
--storage-auto-increase \
--backup-start-time=$CLOUDSQL_BACKUP_START_TIME \
--enable-bin-log \
--tier=$CLOUDSQL_TIER && \
gcloud sql users set-password root % --instance $CLOUDSQL_INSTANCE --password $CLOUDSQL_PASSWORD && \
gcloud sql instances list && \
gcloud sql users list -i $CLOUDSQL_INSTANCE


