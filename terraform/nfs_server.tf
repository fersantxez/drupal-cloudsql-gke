//disk from snapshot -- externally formatted and persistent
resource "google_compute_disk" "default" {
  name     = "${var.disk}"
  type     = "pd-ssd"
  zone     = "${var.zone}"
  snapshot = "${var.snapshot}"
}

output "self_link_compute_disk" {
  value = "${google_compute_disk.default.self_link}"
}

//simple instance with startup script
resource "google_compute_instance" "nfs_server" {
  project      = "${var.project}"
  zone         = "${var.zone}"
  name         = "tf-nfs-1"
  machine_type = "f1-micro"
  tags         = ["${var.tag}"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }

  attached_disk {
    source      = "${google_compute_disk.default.name}"
    device_name = "${var.device_name}"
  }

  network_interface {
    //network    = "${var.network}"
    subnetwork = "${var.subnetwork}"

    access_config = {
      // nat_ip = "${var.FIXME_FIXED_EXTERNAL_IP}"
    }
  }

  metadata_startup_script = <<-EOF
                          #!/bin/bash
			                    mkdir -p ${var.export_path}
                          mount -t ext4 \
                           /dev/${var.device_name}1 ${var.export_path}
                          echo "/dev/${var.device_name}1 ${var.export_path} \
                           ext4 defaults 1 1" >> /etc/fstab
			                    mkdir -p ${var.export_path}/${var.vol_1}
                          mkdir -p ${var.export_path}/${var.vol_2}
                          apt-get install -y nfs-kernel-server
                          systemctl status nfs-kernel-server
                          echo "${var.export_path}/${var.vol_1} *(rw,sync,no_subtree_check,no_root_squash)" \
			    >> /etc/exports
                          echo  "${var.export_path}/${var.vol_2} *(rw,sync,no_subtree_check,no_root_squash)" \
			    >> /etc/exports
                          exportfs -a
                          systemctl restart nfs-kernel-server
                          showmount -e
                          EOF
}

output "nfs_instance_id" {
  value = "${google_compute_instance.nfs_server.self_link}"
}

output "nfs_private_ip" {
  value = "${google_compute_instance.nfs_server.network_interface.0.address}"
}

output "nfs_public_ip" {
  value = "${google_compute_instance.nfs_server.network_interface.0.access_config.0.assigned_nat_ip}"
}
