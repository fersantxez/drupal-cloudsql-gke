resource "kubernetes_storage_class" "slow" {
  metadata {
    name = "slow"
  }

  storage_provisioner = "kubernetes.io/gce-pd"

  parameters {
    type = "pd-standard"
  }
}
