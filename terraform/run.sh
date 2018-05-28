#!/bin/bash
set -o errexit -o nounset -o pipefail

source ./env.sh

#check environment
##################

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
echo "**INFO: Validating environment"
command -v gcloud >/dev/null 2>&1 || { echo "I require gcloud but it's not installed.  Aborting." >&2; exit 1; }

#check required variables are defined - need to be passed on from Dockerfile
#if [ -z "$var" ]; then echo "var is unset"; else echo "var is set to '$var'"; fi
export VARS="ACCOUNT_ID ORG_ID BILLING_ACCOUNT PROJECT REGION ZONE"
for var in $VARS; do
  if [ -z "$var" ]; then echo $var" is unset, exiting" && exit; else echo $var" is set to '${!var}'"; fi
done

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

#create master password
#not required as MASTER_PASSWORD now needs to be passed as var from Dockerfile

#login to gcloud and set project params
#######################################

echo "**INFO: Logging into gcloud and setting up the project"
export LOGGED_ACCOUNT=$(gcloud config list account | awk '{print $3}' | sed -n 2,3p)
export LOGGED_PROJECT=$(gcloud config list|grep project|awk '{print $3}')
if [[ "$LOGGED_ACCOUNT" != "$ACCOUNT_ID" ]] || [[ "$LOGGED_PROJECT" != "$TF_VAR_project" ]] ; then
    echo "**INFO: Not logged in. Logging in as "${ACCOUNT_ID}
    echo "**INFO: Logging into project "${TF_VAR_project}    
    gcloud auth login --brief --no-launch-browser && \
    gcloud config set account ${ACCOUNT_ID} && \
    gcloud config set project ${TF_VAR_project} && \
    gcloud config set compute/zone ${TF_VAR_zone}
fi
echo "**INFO: Logged in as "$LOGGED_ACCOUNT
echo "**INFO: Logged onto project "${TF_VAR_project}

# make sure that the relevant APIs are enabled
##############################################

echo "**INFO: Enabling APIs on project"
export ENABLED_APIS=$(gcloud services list --enabled | awk '{print $1}' | tail -n +1)
#REQUIRED_APIS defined in env.sh as array
for api in "${REQUIRED_APIS[@]}"; do
    echo "**DEBUG: API "$api" is required"
    if [[ " ${ENABLED_APIS[@]} " =~ "${api}" ]]; then
        echo "**INFO: API "$api" is enabled."
    else
        echo "**INFO: API "$api" is disabled. Enabling it..."
        gcloud services enable $api
    fi
done

# create and enable Terraform Service Account
#############################################

#make sure Service Account exists
echo "**INFO: Validating Service Accounts"
export SERVICE_ACCOUNT_LIST=($(gcloud iam service-accounts list  \
    | tail -n +2 | awk '{print $1}')) #double parenthesis for array

if [[ " ${SERVICE_ACCOUNT_LIST[@]} " =~ "${ADMIN_SVC_ACCOUNT}" ]]; then
    echo "Service Account "${ADMIN_SVC_ACCOUNT}" found"
else
    #if it doesnt exist, create it
    echo "**ERROR: Service account "${ADMIN_SVC_ACCOUNT}" not found in project "${TF_VAR_project}
    while true; do
      read -r -p "Do you want to create it? [y/n] " RESPONSE
      case $RESPONSE in
        [yY]) echo "**INFO: Creating service account "${ADMIN_SVC_ACCOUNT}" on project "${TF_VAR_project}
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
    done
fi

#ensure Service Account has required permissions
echo "**INFO: Enabling Service Account roles"
#SA_REQUIRED_ROLES defined in env.sh as array
for role in ${SA_REQUIRED_ROLES[@]}; do
    echo "**INFO: Enabling role "$role
    gcloud projects add-iam-policy-binding ${TF_VAR_project} \
        --member serviceAccount:${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com \
        --role $role #> /dev/null 2>&1
done

#download the service account credentials to the right location
echo "**INFO: Creating Service Account keys"
if [ -f ${TF_VAR_CREDS} ]; then
    echo "**INFO: Service Account keys found at "${TF_VAR_CREDS}
else
    echo "**INFO: No Service Account keys found. Creating them as "${TF_VAR_CREDS}
    gcloud iam service-accounts keys create \
        ${TF_VAR_CREDS} \
        --iam-account ${ADMIN_SVC_ACCOUNT}@${TF_VAR_project}.iam.gserviceaccount.com 
fi

# create bucket for Terraform state
###################################

#remove previous state
rm -Rf .terraform/

#make bucket - catch if it already exists so we don't exit but ask
echo "**INFO: Creating bucket for Terraform state"
if gsutil ls gs://${TF_VAR_bucket_name}; then
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
#############################

echo "**INFO: Updating backend from template"
rm -f backend.tf
cp backend.tf.template backend.tf
sed -i `` "s,__BUCKET__,$TF_VAR_bucket_name,g" backend.tf
sed -i `` "s,__PROJECT__,$TF_VAR_project,g" backend.tf

#finish and run Terraform
#########################

echo "**INFO: Initialization finished. Ready to run with the following backend information (backend.tf):"
cat backend.tf
echo "****** READY ******"
echo "****** now running: "
echo "terraform init"
echo "****** then will run:"
echo "terraform apply"
export GOOGLE_APPLICATION_CREDENTIALS=${TF_VAR_CREDS} && \
terraform init && terraform apply && \
echo "**INFO: ******* FINISHED *******" && \
echo "**INFO: Drupal will be available at the lb_ip address above" && \
exit

echo "**ERROR: Please run again."
