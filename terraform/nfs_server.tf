//disk from snapshot -- externally formatted and persistent
resource "google_compute_disk" "default" {
  name     = "${var.nfs_disk}"
  type     = "pd-ssd"
  zone     = "${var.zone}"
  snapshot = "${var.nfs_snapshot}"
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
    device_name = "${var.nfs_device_name}"
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata_startup_script = <<-EOF
                          #!/bin/bash
			  mkdir -p ${var.nfs_export_path}
                          mount -t ext4 \
                           /dev/${var.nfs_device_name}1 ${var.nfs_export_path}
                          echo "/dev/${var.nfs_device_name}1 ${var.nfs_export_path} \
                           ext4 defaults 1 1" >> /etc/fstab
                          apt-get install -y nfs-kernel-server
                          systemctl status nfs-kernel-server
                          echo "${var.nfs_vol_1} *(rw,sync,no_subtree_check,no_root_squash)" \
			    >> /etc/exports
                          echo "${var.nfs_vol_2} *(rw,sync,no_subtree_check,no_root_squash)" \
			    >> /etc/exports
                          exportfs -a
                          systemctl restart nfs-kernel-server
                          showmount -e
                          EOF
}

//firewall rule allowing a few ports (from the variables file)
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = "${var.ports}"
  }

  target_tags = ["${var.tag}"]
}

output "instance_id" {
  value = "${google_compute_instance.nfs_server.self_link}"
}

output "private_ip" {
  value = "${google_compute_instance.nfs_server.network_interface.0.address}"
}

output "public_ip" {
  value = "${google_compute_instance.nfs_server.network_interface.0.access_config.0.assigned_nat_ip}"
}
