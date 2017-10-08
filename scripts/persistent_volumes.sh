#!/bin/bash

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
    VOLUME=$VOLUME"-vol"

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
