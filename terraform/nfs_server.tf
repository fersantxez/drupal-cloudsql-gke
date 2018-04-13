//simple instance with startup script
resource "google_compute_instance" "nfs_server" {
  project      = "${var.project_name}"
  zone         = "${data.google_compute_zones.available.names[0]}"
  name         = "tf-nfs-1"
  machine_type = "f1-micro"
  tags         = ["${var.tag}"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata_startup_script = <<-EOF
                          #!/bin/bash
                          mount -t ext4 mount -t ext4 \
                           "${var.nfs_disk}""1" "${var.nfs_export_path}"
                          echo "${var.nfs_disk}"" ""${var.nfs_export_path}" \
                           " ext4 defaults 1 1" >> /etc/fstab
                          apt-get install -y nfs-kernel-server
                          systemctl status nfs-kernel-server
                          echo "${var.nfs_vol_1}
*(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
                          echo "${var.nfs_vol_2}
*(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
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
