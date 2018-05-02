#!/bin/bash

#set -o errexit -o nounset -o pipefail

#make sure there's an internet connection
if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "** Internet connectivity is working."
else
  echo "** Internet connectivity is not working. Aborting."
  exit
fi

#check gcloud is installed
echo "***INFO: validating environment"
command -v gcloud >/dev/null 2>&1 || { echo "I require gcloud but it's not installed.  Aborting." >&2; exit 1; }
# init gcloud with the information in env.sh
source ./env.sh

#make sure the project exists


gcloud config set account ${ACCOUNT_ID}
gcloud config set project ${TF_VAR_project}

#make sure service account in the variables exists
echo "***INFO: validating Service Accounts"
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
        exit
    fi
done

if [ "${SA_FOUND}" = false ]; then
    echo "***ERROR: Service account "${ADMIN_SVC_ACCOUNT}" not found in project "${TF_VAR_project}
    echo "Please create it manually and enable the following permissions on it: "
    echo "FIXME: list of permissions"
    #return
fi


# make sure that the relevant APIs are enabled
echo "***INFO: finding project ID for project "TF_VAR_project
export PROJECT_ID=$(gcloud compute project-info describe \
                |grep 'id:' \
                |awk '{print $2}'

echo "***INFO: validating APIs on project ID "${PROJECT_ID}

curl https://console.developers.google.com/apis/api/container.googleapis.com/overview?project=PROJECT_ID
curl https://console.developers.google.com/apis/api/sqladmin.googleapis.com/overview?project=PROJECT_ID
curl https://console.developers.google.com/apis/api/iam.googleapis.com/overview?project=PROJECT_ID
curl https://console.developers.google.com/apis/api/iam.googleapis.com/overview?project=PROJECT_ID