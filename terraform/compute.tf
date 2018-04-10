variable "project_name" {}
variable "region" {}

provider "google" {
 region = "${var.region}"
}

data "google_compute_zones" "available" {}

resource "google_compute_instance" "default" {
 project = "${var.project_name}"
 zone = "${data.google_compute_zones.available.names[0]}"
 name = "tf-compute-1"
 machine_type = "f1-micro"
 tags = ["web"]
 boot_disk {
   initialize_params {
     image = "ubuntu-1604-xenial-v20170328"
   }
 }
 network_interface {
   network = "default"
   access_config {
   }
 }
 metadata_startup_script = <<-EOF
                          #!/bin/bash
                          echo "Hello, Mundo" > index.html
                          nohup busybox httpd -f -p 8080 &
                          EOF
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  target_tags = ["web"]
}

output "instance_id" {
 value = "${google_compute_instance.default.self_link}"
}
