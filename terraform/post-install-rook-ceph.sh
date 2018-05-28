#!/bin/bash

#set -o errexit -o nounset -o pipefail

source ./env.sh

#set zone for cloud shell
gcloud config set compute/zone ${TF_VAR_zone}
#get kubernetes credentials
gcloud container clusters get-credentials ${TF_VAR_gke_cluster_name} 
#add cluster role binding for Rook operator
kubectl create clusterrolebinding my-cluster-admin-binding --clusterrole=cluster-admin --user=${ACCOUNT_ID} && \
#deploy rook
kubectl create -f ./rook-operator.yaml && \
kubectl create -f ./rook-cluster.yaml && \
kubectl create -f ./rook-filesystem.yaml && \
kubectl create -f ./rook-tools.yaml 
#install ceph on all nodes
export GKE_NODES=$(kubectl get node | tail -n +2 | awk '{print $1}') 
for node in ${GKE_NODES}; do
  echo "**INFO: installing Ceph client on node: "${node}
  gcloud compute ssh ${node} --command "sudo apt-get update -y && sudo apt-get  install -y ceph-fs-common ceph-common"
done

