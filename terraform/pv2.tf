resource "kubernetes_persistent_volume" "vol_2" {
    metadata {
        name = "${var.vol_2}"
    }
    spec {
        access_modes = ["ReadWriteMany"]
        capacity {
            storage = "${var.vol_2_size}"
        }
        persistent_volume_source {
            nfs {
                server = "${google_compute_instance.nfs_server.network_interface.0.address}"
                path = "/${var.vol_2}"
            }
        }
    }
}