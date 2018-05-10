//firewall rule: allow all traffic internal to the network
resource "google_compute_firewall" "internal" {
  name        = "internal"
  project     = "${var.project}"
  network     = "${var.network}"
  description = "allow all traffic between instances in the network with the same tag"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = "${var.ports}"
  }

  allow {
    protocol = "udp"
    ports    = "${var.ports}"
  }

  source_tags = ["${var.tag}"]
  target_tags = ["${var.tag}"]
}

resource "google_compute_firewall" "external" {
  name        = "external"
  project     = "${var.project}"
  network     = "${var.network}"
  description = "allow external traffic towards instances in the network in some ports"

  allow {
    protocol = "tcp"
    ports    = "${var.ports}"
  }

  allow {
    protocol = "udp"
    ports    = "${var.ports}"
  }

  target_tags = ["${var.tag}"]
}
