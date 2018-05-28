#!/bin/bash
export VERSION="v0.3-nfs"
export IMAGE="fernandosanchez/clouddrupal:"${VERSION}

#validate docker works
command -v docker >/dev/null 2>&1 || { echo "I require docker but it's not installed.  Aborting." >&2; exit 1; }


#validate or force setting env vars, then run from docker 
#otherwise prompt for interactive input
declare -a VARS=( \
    "ACCOUNT_ID" \
    "ORG_ID" \
    "BILLING_ACCOUNT" \
    "PROJECT" \
    "REGION" \
    "ZONE" \
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
while true; do
    if [[ ${#TF_VAR_master_password} -le 19 ]]; then
        echo "**ERROR: MASTER PASSWORD must be set and AT LEAST 20 characters long"
        echo "**INFO: PLEASE ENTER ***MASTER PASSWORD*** (needs to be AT LEAST 20 characters long)" 
        read -s TF_VAR_master_password
    else
        echo "**INFO: MASTER PASSWORD saved, "${#TF_VAR_master_password}" characters long."
        break
    fi
done

sudo docker run \
    -it \
    -e ACCOUNT_ID=${ACCOUNT_ID} \
    -e ORG_ID=${ORG_ID} \
    -e BILLING_ACCOUNT=${BILLING_ACCOUNT} \
    -e PROJECT=${PROJECT} \
    -e REGION=${REGION} \
    -e ZONE=${ZONE} \
    -e MASTER_PASSWORD=${MASTER_PASSWORD} \
    ${IMAGE}
