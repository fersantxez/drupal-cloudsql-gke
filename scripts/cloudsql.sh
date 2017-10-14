#Create CloudSQL instance

source ./env.sh

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


