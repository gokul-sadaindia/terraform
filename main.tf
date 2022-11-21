

provider "google" {
  credentials = "${file("/Users/gokul.vijayakumar/Downloads/playground-s-11-f667ac35-8705e4fed41c.json")}"
  project     = "my-project-id"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_network" "net" {
  name = "my-network"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnetwork"
  network       = google_compute_network.net.id
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
}

resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.net.id
}

resource "google_compute_address" "address" {
  count  = 2
  name   = "nat-manual-ip-${count.index}"
  region = google_compute_subnetwork.subnet.region
}

resource "google_compute_router_nat" "nat_manual" {
  name   = "my-router-nat"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.address.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}