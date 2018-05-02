#!/bin/bash

#set -o errexit -o nounset -o pipefail

#check gcloud is installed
command -v gcloud >/dev/null 2>&1 || { echo "I require gcloud but it's not installed.  Aborting." >&2; exit 1; }

# init gcloud with the information in env.sh
source ./env.sh

gcloud config set account ${ACCOUNT_ID}
gcloud config set project ${TF_VAR_project}

#make sure somebody has created the service account in the variables
export SERVICE_ACCOUNT_LIST=$(gcloud iam service-accounts list  \
    | tail -n +3  \
    | awk '{print $1}' \
    )

export SA_FOUND=false
for i in ${SERVICE_ACCOUNT_LIST};do
    echo "searching... "$i
    if [ $i = "${ADMIN_SVC_ACCOUNT}" ] ; then
        export SA_FOUND=true
        echo "Service Account "$i" found"
        break
    fi
done

if [ "${SA_FOUND}" = false ]; then
    echo "***ERROR: Service account "${ADMIN_SVC_ACCOUNT}" not found in project "${TF_VAR_project}
    echo "Please create it manually and enable the following permissions on it: "
    echo "FIXME: list of permissions"
    #return
fi