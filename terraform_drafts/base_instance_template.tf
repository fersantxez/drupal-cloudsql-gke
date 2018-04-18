variable "project_name" {}
variable "region" {}
variable "zone" {}

variable "ports" {
  description = "Ports the HTTP server listens on"
  type        = "list"
  default     = [8080, 8081]
}

provider "google" {
  region = "${var.region}"
}

data "google_compute_zones" "available" {}

resource "google_compute_instance_template" "webserver_template" {
  name_prefix          = "webserver-template-"
  description          = "This template is used to create web server instances."
  region               = "${var.region}"
  machine_type         = "f1-micro"
  tags                 = ["web"]
  instance_description = "description assigned to instances"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }

  network_interface {
    network = "default"
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata_startup_script = <<-EOF
                          #!/bin/bash
                          echo "Hello, Mondo Dificile" > index.html
                          nohup busybox httpd -f -p 8080 &
                          EOF
}

resource "google_compute_instance_group_manager" "webserver_instance_group_manager" {
  name               = "webserver-instance-group-manager"
  instance_template  = "${google_compute_instance_template.webserver_template.self_link}"
  base_instance_name = "instance-group-manager"
  zone               = "${var.zone}"
  target_size        = "1"
}

output "webserver_manager_self_link" {
  value = "${google_compute_instance_group_manager.webserver_instance_group_manager.self_link}"
}

output "webserver_manager_nat_ip" {
  value = "${google_compute_instance_group_manager.webserver_instance_group_manager.access_config.nat_ip}"
}
