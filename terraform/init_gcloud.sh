#!/bin/bash

set -o errexit -o nounset -o pipefail

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

gcloud auth login --no-launch-browser && \
gcloud config set account ${ACCOUNT_ID}
gcloud config set project ${TF_VAR_project}

# make sure that the relevant APIs are enabled
echo "***INFO: finding project ID for project "${TF_VAR_project}
export PROJECT_ID=$(gcloud compute project-info describe \
                |grep 'id:' \
                |awk '{print $2}')

echo "***INFO: validating APIs on project ID "${PROJECT_ID}

gcloud services enable compute.googleapis.com && \
gcloud services enable container.googleapis.com && \
gcloud services enable dns.googleapis.com && \
gcloud services enable iam.googleapis.com && \
gcloud services enable replicapool.googleapis.com && \
gcloud services enable replicapoolupdater.googleapis.com && \
gcloud services enable resourceviews.googleapis.com && \
gcloud services enable sql-component.googleapis.com && \
gcloud services enable sqladmin.googleapis.com && \
gcloud services enable storage-api.googleapis.com && \
gcloud services enable storage-component.googleapis.com 

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
        break
    fi
done

if [ "${SA_FOUND}" = false ]; then
    echo "***ERROR: Service account "${ADMIN_SVC_ACCOUNT}" not found in project "${TF_VAR_project}
    echo "Do you want me to create it and enable the required permissions: "
    echo "roles/iam.organizationRoleAdmin"
    echo "roles/iam.roleAdmin"
    echo "roles/compute.storageAdmin" 
    echo "roles/compute.securityAdmin"
    echo "roles/compute.networkAdmin"
    echo "roles/compute.instanceAdmin.v1"
    read -p  "***(y/n): " RESPONSE
    while true; do
    case $RESPONSE in
        [yY]) echo "***Creating service account "${ADMIN_SVC_ACCOUNT}" on project "${TF_VAR_project}
            #create service account
            gcloud iam service-accounts create ${ADMIN_SVC_ACCOUNT} \
                --display-name "Terraform Admin Service Account" && \
            #add relevant permissions
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/iam.organizationRoleAdmin' >/dev/null 2>&1
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/iam.roleAdmin' >/dev/null 2>&1
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/iam.serviceAccountAdmin' >/dev/null 2>&1
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/compute.storageAdmin' >/dev/null 2>&1
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/storage.objectAdmin' >/dev/null 2>&1
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/compute.securityAdmin' >/dev/null 2>&1
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/compute.networkAdmin' >/dev/null 2>&1
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/compute.instanceAdmin.v1' >/dev/null 2>&1
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/containers.clusters.create' >/dev/null 2>&1
            break                                                                            
            ;;
        [nN]) echo "***Exiting. Please create the Service Account and assign IAM roles manually or re-run this script"
            exit
            ;;
        *) "**Invalid input. Please select [y] or [n]"
            ;;
    esac
    done
fi

#download the service account credentials to the right location
gcloud iam service-accounts keys create \
    ${TF_VAR_CREDS} \
    --iam-account ${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com

#make bucket
gsutil mb -l ${TF_VAR_region} "gs://"${TF_VAR_bucket_name}

echo "***Initialization finished. Please remember to edit 'backend.tf' and add your bucket name "${TF_VAR_bucket_name}
echo "then run 'terraform init' 'terraform apply'"

#FIXME: missing the snapshot creation





