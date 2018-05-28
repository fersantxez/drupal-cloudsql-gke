#!/bin/bash
export VERSION="v0.3-nfs"
export IMAGE="fernandosanchez/clouddrupal:"${VERSION}

#validate or force setting env vars, then run from docker 
#otherwise prompt for interactive input
declare -a VARS=( \
    "ACCOUNT_ID" \
    "ORG_ID" \
    "BILLING_ACCOUNT" \
    "PROJECT" \
    "REGION" \
    "ZONE" \
    "MASTER_PASSWORD" \
)

for var in "${VARS[@]}"; do
    while [ -z "${!var}" ]; do 
        echo "**ERROR: "$var" is unset or empty."
        read -r -p "**INFO: Please enter a value for "$var" : " $var
    done
    echo "**DEBUG: "$var" is set to "${!var}
done

for var in "${VARS[@]}"; do
    echo "**DEBUG: "$var" is set to "${!var}
done

#any validation
#check MASTER_PASSWORD is at least 20 chars long
if [[ ${#MASTER_PASSWORD} -le 19 ]]; then
    echo "**ERROR: MASTER PASSWORD must be AT LEAST 20 characters long"
    exit
else
    echo "**INFO: MASTER PASSWORD saved, "${#MASTER_PASSWORD}" characters long."
fi

sudo docker run \
    -it \
    -e ACCOUNT_ID=${ACCOUNT_ID} \
    -e ORG_ID=${ORG_ID} \
    -e BILLING_ACCOUNT=${BILLING_ACCOUNT} \
    -e PROJECT=${PROJECT} \
    -e REGION=${REGION} \
    -e ZONE=${ZONE} \
    ${IMAGE}
