resource "kubernetes_persistent_volume_claim" "pvc_2" {
  metadata {
    name = "${var.vol_2}-claim"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "${kubernetes_storage_class.slow.metadata.0.name}"

    resources {
      requests {
        storage = "${var.vol_2_size}"
      }
    }

    volume_name = "${kubernetes_persistent_volume.vol_2.metadata.0.name}"
  }
}
