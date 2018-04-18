//GKE cluster

resource "google_container_cluster" "primary" {
  name               = "${var.gke_cluster_name}"
  zone               = "${var.zone}"
  initial_node_count = "${var.gke_cluster_size}"

  master_auth {
    username = "${var.gke_username}"
    password = "${var.master_password}"
  }
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}

output "endpoint" {
  value = "${google_container_cluster.primary.endpoint}"
}
