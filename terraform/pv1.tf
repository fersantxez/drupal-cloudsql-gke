resource "kubernetes_persistent_volume" "vol_1" {
  metadata {
    name = "${var.vol_1}"
  }

  spec {
    access_modes = ["ReadWriteMany"]

    capacity {
      storage = "${var.vol_1_size}"
    }

    storage_class_name = "${kubernetes_storage_class.slow.metadata.0.name}"

    persistent_volume_source {
      nfs {
        server = "${google_compute_instance.nfs_server.network_interface.0.address}"
        path   = "${var.export_path}/${var.vol_1}"
      }
    }
  }
}
