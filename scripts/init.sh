#init environment

source ./env.sh

echo -n "**INPUT: Enter MySQL password for user "$CLOUDSQL_USERNAME":"
read -s CLOUDSQL_PASSWORD

#get project credentials
gcloud config set project $PROJECT_NAME

#show configuration
gcloud config list
