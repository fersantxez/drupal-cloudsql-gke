//disk from snapshot -- externally formatted and persistent
resource "google_compute_disk" "default" {
  name = "${var.disk}"
  type = "${var.raw_disk_type}"
  zone = "${var.zone}"

  #snapshot = "${var.snapshot}" #blank disk by default
}

output "self_link_compute_disk" {
  value = "${google_compute_disk.default.self_link}"
}

//template for NFS server startup script
data "template_file" "startup_script" {
  template = "${file("nfs_server_startup.sh")}"

  vars {
    device_name = "${var.device_name}"
    export_path = "${var.export_path}"
    vol_1       = "${var.vol_1}"
    vol_2       = "${var.vol_2}"
  }
}

//simple instance with startup script
resource "google_compute_instance" "nfs_server" {
  project      = "${var.project}"
  zone         = "${var.zone}"
  name         = "tf-nfs-server"
  machine_type = "${var.nfs_machine_type}"
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

  metadata_startup_script = "${data.template_file.startup_script.rendered}"
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
