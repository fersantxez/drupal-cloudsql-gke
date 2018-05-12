#!/bin/bash
set -o errexit -o nounset -o pipefail

source ./env.sh

#make sure there is an internet connection
if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "**INFO: Internet connectivity is working."
else
  echo "**ERROR: Internet connectivity is not working. Aborting."
  #exit
fi

#make sure we're running on linux to avoid bash weirdness
unameOut="$(uname -s)"
if [[ $unameOut = *"inux"* ]]; then
  echo "**INFO: Running on Linux"
else
  echo "**ERROR: I can only run on Linux. Exiting"
  exit
fi

#check gcloud is installed
echo "**INFO: validating environment"
command -v gcloud >/dev/null 2>&1 || { echo "I require gcloud but it's not installed.  Aborting." >&2; exit 1; }

#login to gcloud and set project params
echo "**INFO: logging into gcloud and setting up the project"
export LOGGED_ACCOUNT=$(gcloud config list account | awk '{print $3}' | sed -n 2,3p)
echo "**DEBUG: logged account is ["${LOGGED_ACCOUNT}"]"
echo "**DEBUG: account ID is ["${ACCOUNT_ID}"]"
if [[ "$LOGGED_ACCOUNT" == "$ACCOUNT_ID" ]]; then
    echo "**INFO: Logged in as "$LOGGED_ACCOUNT
else
    echo "**INFO: Not logged in. Logging in as "${ACCOUNT_ID}
    gcloud auth login --brief --no-launch-browser && \
    #gcloud projects create \
    #  ${TF_VAR_project} --name=${TF_VAR_project} --organization=${TF_VAR_org_id} \
    #  --enable-cloud-apis --set-as-default && \
    gcloud config set account ${ACCOUNT_ID} && \
    gcloud config set project ${TF_VAR_project} && \
    gcloud config set compute/zone ${TF_VAR_zone}
fi

# make sure that the relevant APIs are enabled
echo "**INFO: enabling APIs on project"

export ENABLED_APIS=$(gcloud services list --enabled | awk '{print $1}' | tail -n +1)

for ea in $ENABLED_APIS; do
    echo "**DEBUG: ENABLED API ["$ea"]"
done

declare -a REQUIRED_APIS=(\
    "container.googleapis.com" \
    "compute.googleapis.com" \
    "dns.googleapis.com" \
    'iam.googleapis.com' \
    'replicapool.googleapis.com' \
    'replicapoolupdater.googleapis.com' \
    'resourceviews.googleapis.com' \
    'sql-component.googleapis.com' \
    'sqladmin.googleapis.com' \
    'storage-api.googleapis.com' \
    'storage-component.googleapis.com' \
    'cloudresourcemanager.googleapis.com' \
 )
for ra in "${REQUIRED_APIS[@]}"; do
    echo "**DEBUG: REQUIRED API ["$ra"]"
done

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

for api in "${REQUIRED_APIS[@]}"; do
    echo "**DEBUG: API "$api" is required"
    if [[ " ${ENABLED_APIS[@]} " =~ "${api}" ]]; then
        echo "**INFO: API "$api" is enabled."
    else
        echo "**INFO: API "$api" is disabled. Enabling it..."
        gcloud services enable $api
    fi
done

#make sure Service Account exists
echo "**INFO: validating Service Accounts"
export SERVICE_ACCOUNT_LIST=$(gcloud iam service-accounts list  \
    | tail -n +2 | awk '{print $1}')            #get first column. SA description does not have spaces.

export SA_FOUND=false
for i in ${SERVICE_ACCOUNT_LIST};do
    echo "Searching... "$i
    if [ $i = "${ADMIN_SVC_ACCOUNT}" ] ; then
        export SA_FOUND=true
        echo "Service Account "$i" found"
        break
    fi
done

if [ "${SA_FOUND}" = false ]; then
    echo "**ERROR: Service account "${ADMIN_SVC_ACCOUNT}" not found in project "${TF_VAR_project}
    echo "**ERROR: Do you want me to create it?"
    read -p "** (y/n): " RESPONSE
    case $RESPONSE in
        [yY]) echo "**INFO: Creating service account "${ADMIN_SVC_ACCOUNT}" on project "${TF_VAR_project}
            #create service account
            gcloud iam service-accounts create ${ADMIN_SVC_ACCOUNT} \
                --display-name ${ADMIN_SVC_ACCOUNT}
            break                                                                            
            ;;
        [nN]) echo "**ERROR: Terraform Service account is required. Exiting. "
            exit
            ;;
        *) echo "**ERROR: Invalid input. Please select [y] or [n]"
            ;;
    esac
fi

#Ensure Service Account has required permissions
echo "**INFO: Enabling Service Account roles"

declare -a SA_REQUIRED_ROLES=(\
    "roles/iam.roleAdmin" \
    "roles/iam.serviceAccountAdmin" \
    "roles/iam.serviceAccountActor" \
    "roles/iam.serviceAccountKeyAdmin" \
    "roles/resourcemanager.projectIamAdmin" \
    "roles/compute.storageAdmin" \
    "roles/storage.admin" \
    "roles/storage.objectAdmin" \
    "roles/compute.securityAdmin" \
    "roles/compute.networkAdmin" \
    "roles/compute.instanceAdmin.v1" \
    "roles/cloudsql.admin" \
    "roles/container.admin" \
    "roles/dns.admin" \
    )

for role in ${SA_REQUIRED_ROLES[@]}; do
    echo "**INFO: enabling role "$role
    gcloud projects add-iam-policy-binding ${TF_VAR_project} \
        --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
        --role $role \
        > /dev/null 2>&1
done

#download the service account credentials to the right location
echo "**INFO: creating Service Account keys"
if [ -f ${TF_VAR_CREDS} ]; then
    echo "**INFO: Service Account keys found at "${TF_VAR_CREDS}
else
    echo "**INFO: No Service Account keys found. Creating them as "${TF_VAR_CREDS}
    gcloud iam service-accounts keys create \
        ${TF_VAR_CREDS} \
        --iam-account ${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com 
fi
export GOOGLE_DEFAULT_CREDENTIALS=${TF_VAR_CREDS}

#make bucket - catch if it already exists so we don't exit but ask
echo "**INFO: creating bucket for Terraform state"
if `gsutil ls gs://${TF_VAR_bucket_name}` ; then 
    echo "**INFO: Terraform state bucket "${TF_VAR_bucket_name} "found."
else 
    echo "**INFO: Terraform state bucket "${TF_VAR_bucket_name} "does not exist."
    read -r -p "Do you want to create it? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            gsutil mb -l ${TF_VAR_region} "gs://"${TF_VAR_bucket_name}  
            ;;
        *)
            echo "Terraform state bucket is needed. Exiting."
            exit
            ;;
    esac
fi

#update backend template file
echo "**INFO: updating backend from template"
rm -f backend.tf
cp backend.tf.template backend.tf
sed -i `` "s,__BUCKET__,$TF_VAR_bucket_name,g" backend.tf
sed -i `` "s,__PROJECT__,$TF_VAR_project,g" backend.tf

#remove previous state
rm -Rf .terraform/

#create master password
echo "**INFO: PLEASE ENTER ***MASTER PASSWORD*** (needs to be AT LEAST 20 chars LONG)" 
read -s TF_VAR_master_password
#echo "export TF_VAR_master_password=${TF_VAR_master_password}" >> ./env.sh

echo "**INFO: Initialization finished. Ready to run with the following backend information (backend.tf):"
cat backend.tf
echo "****** READY ******"
echo "****** now running: "
echo "terraform init"
echo "****** then will run:"
echo "terraform apply"

echo "**INFO: Initializing and running Terraform:"
terraform init && terraform apply && \
echo "**INFO: ******* FINISHED *******" && \
echo "**INFO: Drupal will be available at the lb_ip address above" && \
exit

echo "**ERROR: please run 'terraform apply' again"