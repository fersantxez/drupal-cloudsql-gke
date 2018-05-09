#!/bin/bash

source ./env.sh

#make sure there is an internet connection
if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "** Internet connectivity is working."
else
  echo "** Internet connectivity is not working. Aborting."
  #exit
fi

#check gcloud is installed
echo "***INFO: validating environment"
command -v gcloud >/dev/null 2>&1 || { echo "I require gcloud but it's not installed.  Aborting." >&2; exit 1; }

#login to gcloud and set project params
echo "***INFO: logging into gcloud and setting up the project"
gcloud auth login --no-launch-browser && \
gcloud config set account ${ACCOUNT_ID} && \
gcloud config set project ${TF_VAR_project} && \
gcloud config set compute/zone ${TF_VAR_zone}

# make sure that the relevant APIs are enabled
echo "***INFO: finding project ID for project "${TF_VAR_project}
export PROJECT_ID=$(gcloud compute project-info describe \
                |grep 'id:' \
                |awk '{print $2}')

echo "***INFO: enabling APIs on project ID "${PROJECT_ID}
gcloud services enable \
compute.googleapis.com \
container.googleapis.com \
dns.googleapis.com \
iam.googleapis.com \
replicapool.googleapis.com \
replicapoolupdater.googleapis.com \
resourceviews.googleapis.com \
sql-component.googleapis.com \
sqladmin.googleapis.com \
storage-api.googleapis.com \
storage-component.googleapis.com \
cloudresourcemanager.googleapis.com

#make sure service account in the variables exists
echo "***INFO: validating Service Accounts"
export SERVICE_ACCOUNT_LIST=$(gcloud iam service-accounts list  \
    | tail -n +2 | awk '{print $1}')            #get first column. SA description does not have spaces.

export SA_FOUND=false
for i in ${SERVICE_ACCOUNT_LIST};do
    echo "Searching... "$i
    if [ $i = "${ADMIN_SVC_ACCOUNT}" ] ; then
        export SA_FOUND=true
        echo "Service Account "$i" found"
        echo "Please make sure it has the right permissions, or delete it manually and re-create it using this script."
        break
    fi
done

if [ "${SA_FOUND}" = false ]; then
    echo "**ERROR: Service account "${ADMIN_SVC_ACCOUNT}" not found in project "${TF_VAR_project}
    echo "**Do you want me to create it and enable the required permissions?"" (y/n): "
    while true; do
    read -p "** Enter (y/n): " RESPONSE
    case $RESPONSE in
        [yY]) echo "***INFO: Creating service account "${ADMIN_SVC_ACCOUNT}" on project "${TF_VAR_project}
            #create service account
            gcloud iam service-accounts create ${ADMIN_SVC_ACCOUNT} \
                --display-name ${ADMIN_SVC_ACCOUNT}  \
            #add relevant permissions
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/iam.roleAdmin'  
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/iam.serviceAccountAdmin'
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/iam.serviceAccountActor'
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/iam.serviceAccountKeyAdmin'
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/resourcemanager.projectIamAdmin'       
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/compute.storageAdmin'  
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/storage.objectAdmin'  
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/compute.securityAdmin'  
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/compute.networkAdmin'  
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/compute.instanceAdmin.v1'  
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/cloudsql.admin'
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/container.admin'
            gcloud projects add-iam-policy-binding ${TF_VAR_project} \
                --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
                --role 'roles/dns.admin'
            break                                                                            
            ;;
        [nN]) echo "***ERROR: Please create the Service Account and assign IAM roles manually or re-run this script. Exiting. "
            exit
            ;;
        *) echo "**ERROR: Invalid input. Please select [y] or [n]"
            ;;
    esac
    done
fi

#download the service account credentials to the right location
echo "**INFO: creating Service Account keys"
gcloud iam service-accounts keys create \
    ${TF_VAR_CREDS} \
    --iam-account ${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com && \
export GOOGLE_DEFAULT_CREDENTIALS=${TF_VAR_CREDS}

#make bucket
echo "**INFO: creating bucket for Terraform state"
gsutil mb -l ${TF_VAR_region} "gs://"${TF_VAR_bucket_name}

#update backend template file
echo "**INFO: updating backend from template"
rm -f backend.tf±—
cp backend.tf.template backend.tf
sed -i `` "s,__BUCKET__,$TF_VAR_bucket_name,g" backend.tf
sed -i `` "s,__PROJECT__,$TF_VAR_project,g" backend.tf

echo "**INFO: Initialization finished. Ready to run with the following backend information on 'backend.tf':"
cat backend.tf
echo "**INFO: now run 'terraform init' and then 'terraform apply'"





