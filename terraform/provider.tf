provider "google" {
  region = "${var.region}"
}

provider "kubernetes" {
  host     = "${google_container_cluster.primary.endpoint}"
  username = "${var.gke_username}"
  password = "${var.master_password}"

  client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

//FIXME: Enable Helm provider to enable deploying workloads to GKE/K8s through Helm
//https://github.com/mcuadros/terraform-provider-helm/wiki
//You must have Kubernetes installed. We recommend version 1.4.1 or later.
//You should also have a local configured copy of kubectl.
//You should also have a local configured copy of helm.
//You must have Tiller installed on Kubernetes.
//provider "helm" {
//    kubernetes {
//        host     = "${google_container_cluster.primary.endpoint}"
//        username = "${var.gke_username}"
//        password = "${var.master_password}"
//
//        client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
//        client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
//        cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
//    }
//}

