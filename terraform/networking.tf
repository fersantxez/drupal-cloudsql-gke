//Networking: external_ip and DNS name


//external IP that should be used in the external load balancer / FIXME: not working
resource "google_compute_global_address" "frontend" {
  project = "${var.project}"
  name = "${var.ext_ip_name}"
}

output "frontend-ip"{
  value = "${google_compute_global_address.frontend.address}"
}

//DNS record

resource "google_dns_managed_zone" "myzone" {
  name     = "${var.dns_zone_name}"
  dns_name = "${var.dns_name}."
}

resource "google_dns_record_set" "frontend" {
  name = "${google_dns_managed_zone.myzone.dns_name}"
  managed_zone = "${google_dns_managed_zone.myzone.name}"
  type = "A"
  ttl  = 300

  rrdatas = ["${kubernetes_service.cloud-drupal.load_balancer_ingress.0.ip}"]
}

resource "google_dns_record_set" "www" {
  name = "www.${google_dns_managed_zone.myzone.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.myzone.name}"

  rrdatas = ["${google_dns_managed_zone.myzone.dns_name}"]
}