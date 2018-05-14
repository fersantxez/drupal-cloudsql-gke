//Networking: network,subnet, external_ip and DNS name

//network and subnetwork
resource "google_compute_network" "mynetwork" {
  name                    = "${var.network}"
  auto_create_subnetworks = "true"
}

output "network" {
  value = "${google_compute_network.mynetwork.self_link}"
}

resource "google_compute_subnetwork" "mysubnetwork" {
  name          = "${var.subnetwork}"
  ip_cidr_range = "${var.subnetcidr}"
  network       = "${google_compute_network.mynetwork.self_link}"
  region        = "${var.region}"
}

output "subnetwork" {
  value = "${google_compute_subnetwork.mysubnetwork.self_link}"
}

resource "google_compute_route" "mynetwork-default-route" {
  name             = "default-route"
  dest_range       = "0.0.0.0/24"
  network          = "${google_compute_network.mynetwork.name}"
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

//external IP that should be used in the external load balancer
resource "google_compute_address" "frontend" {
  project = "${var.project}"
  name    = "${var.ext_ip_name}"
  region  = "${var.region}"
}

output "frontend-ip" {
  value = "${google_compute_address.frontend.address}"
}

//DNS record
/*
resource "google_dns_managed_zone" "myzone" {
  name     = "${var.dns_zone_name}"
  dns_name = "${var.dns_name}."
}

resource "google_dns_record_set" "frontend" {
  name = "${google_dns_managed_zone.myzone.dns_name}"
  managed_zone = "${google_dns_managed_zone.myzone.name}"
  type = "A"
  ttl  = 300

  //rrdatas = ["${kubernetes_service.cloud-drupal.load_balancer_ingress.0.ip}"]
  rrdatas = ["${google_compute_address.frontend.address}"]
}

output "frontend-URL"{
  value = "${google_dns_record_set.frontend.name}"
}

resource "google_dns_record_set" "www" {
  name = "www.${google_dns_managed_zone.myzone.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.myzone.name}"

  rrdatas = ["${google_dns_managed_zone.myzone.dns_name}"]
}

output "www-URL"{
  value = "${google_dns_record_set.www.name}"
}
*/

