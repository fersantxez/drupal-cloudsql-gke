#!/bin/bash

export VARS_FILE="./env.list"
export VERSION="v0.3-nfs"
export IMAGE="fernandosanchez/cloudrupal:"${VERSION}

#validate or force setting env vars, then run from docker 
#if there's an env file, run from that
if [ -e ${VARS_FILE}]; then
    echo "**DEBUG: reading environment from "${VARS_FILE}
    sudo docker run \
    -it \
    -env-file ${VARS_FILE}
    ${IMAGE}
#otherwise prompt for interactive input
else
    echo "**DEBUG: "${VARS_FILE}" not found. Reading environment interactively"
    export VARS="ACCOUNT_ID ORG_ID BILLING_ACCOUNT PROJECT REGION ZONE MASTER_PASSWORD"
    for var in $VARS; do
    while [ -z "$var" ]; do 
        echo "**ERROR: "$var" is unset or empty."
        read -r -p "**INFO: Please enter a value for "$var var
    done
    echo "**DEBUG: "$var" is set to '$var'"
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
fi