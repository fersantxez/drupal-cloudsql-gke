//scalable *regional* *external* instance template with TCP / L4 load balancer
//https://cloud.google.com/community/tutorials/modular-load-balancing-with-terraform

//instance template
resource "google_compute_instance_template" "webserver_template" {
  name_prefix          = "webserver-template-"
  description          = "This template is used to create web server instances."
  region               = "${var.region}"
  machine_type         = "f1-micro"
  tags                 = ["${var.tag}"]
  instance_description = "description assigned to instances"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    boot         = true
    source_image = "ubuntu-1604-xenial-v20170328"
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

//healthcheck
resource "google_compute_http_health_check" "default" {
  name                = "default-hc" //no underscores (error here) and no dashes (error referending it from target pool) 
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10           # 50 seconds
}

//target_pool to be used in the group manager. For internal groups this would be a google_compute_region_backend_service
resource "google_compute_target_pool" "webserver_target_pool" {
  project = "${var.project_name}"
  name    = "${var.name}"
  region  = "${var.region}"

  //session_affinity = "${var.session_affinity}"

  health_checks = [
    "${google_compute_http_health_check.default.name}",
  ]
}

// group manager - instantiates an instance_template and includes the instances in a target_pool
// uses the healthcheck to make sure they're alive
resource "google_compute_instance_group_manager" "webserver_instance_group_manager" {
  name               = "webserver-instance-group-manager"
  base_instance_name = "webserver-instance-group-manager"
  instance_template  = "${google_compute_instance_template.webserver_template.self_link}"
  zone               = "${var.zone}"
  target_size        = "${var.num_instances}"

  target_pools = ["${google_compute_target_pool.webserver_target_pool.self_link}"] //instances are added to this pool

  named_port {
    name = "customhttp"
    port = "${var.ports[0]}"
  }

  auto_healing_policies {
    health_check      = "${google_compute_http_health_check.default.self_link}"
    initial_delay_sec = 300
  }
}

//forwarding rule 
resource "google_compute_forwarding_rule" "default" {
  project               = "${var.project_name}"
  name                  = "${var.name}"
  target                = "${google_compute_target_pool.webserver_target_pool.self_link}"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "${var.ports[0]}"
}

//firewall - external.
resource "google_compute_firewall" "default-lb-fw" {
  project = "${var.project_name}"
  name    = "${var.name}"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["${var.ports[0]}"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.tag}"]
}

//output -- external IP?
output "webserver_manager_self_link" {
  value = "${google_compute_instance_group_manager.webserver_instance_group_manager.self_link}"
}

//nat_ip - TBD
//output "webserver_manager_nat_ip" {
//  value = "${google_compute_instance_group_manager.webserver_instance_group_manager.access_config.nat_ip}"
//}

