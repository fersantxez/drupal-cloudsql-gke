//simple instance with startup script
resource "google_compute_instance" "default" {
  project      = "${var.project_name}"
  zone         = "${data.google_compute_zones.available.names[0]}"
  name         = "tf-compute-1"
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
                          echo "Hello, Mundo" > index.html
                          nohup busybox httpd -f -p 8080 &
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
  value = "${google_compute_instance.default.self_link}"
}

output "public_ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.assigned_nat_ip}"
}
