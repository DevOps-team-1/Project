resource "google_compute_instance" "my_ansible_instance" {
  name           = "my-ansible-instance"
  machine_type   = "e2-medium"
  can_ip_forward = false

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20201014"
    }
  }
}


resource "google_compute_network" "vpc_network" {
  name                    = "terraform-vpc-145"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "my_firewall" {
  name    = "terraformfirewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }
}