//GKE cluster

resource "google_container_cluster" "primary" {
  name               = "${var.gke_cluster_name}"
  zone               = "${var.zone}"
  network            = "${var.network}"
  subnetwork         = "${var.subnetwork}"
  initial_node_count = "${var.gke_cluster_size}"

  master_auth {
    username = "${var.gke_username}"
    password = "${var.master_password}"
  }

  node_config {
    tags         = ["${var.tag}"]
    machine_type = "${var.gke_machine_type}"
  }

  enable_legacy_abac = true
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "gke_client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "gke_client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "gke_cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}

output "gke_endpoint" {
  value = "${google_container_cluster.primary.endpoint}"
}
