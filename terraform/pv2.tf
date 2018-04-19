resource "kubernetes_persistent_volume" "vol_2" {
    metadata {
        name = "${var.nfs_vol_2}"
    }
    spec {
        capacity {
            storage = "${var.nfs_vol_2_size}"
        }
        access_modes = ["ReadWriteMany"]
        persistent_volume_source {
            nfs {
                server = "${google_compute_instance.nfs_server.network_interface.0.address}"
                path = "${var.nfs_vol_2}"
            }
        }
    }
}