provider "google" {
  credentials = file("prefab-mountain-292413-296112-ac76d2510eff.json")
  project     = "prefab-mountain-292413-296112"
  region      = "us-central1"
  zone        = "us-central1-a"
  user_project_override = true

}

resource "google_compute_instance" "test_instance" {
  name = "ubuntuimage"
  count = 1
  machine_type = "e2-medium"
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20201014"
    }
  }

  connection {
    host = self.network_interface.0.access_config.0.nat_ip
    type = "ssh"
    user = var.user
    private_key = "id_rsa"
    agent = "false"
    }

  metadata_startup_script ="sudo apt-get update; sudo apt install software-properties-common; sudo apt-add-repository --yes --update ppa:ansible/ansible; sudo apt install ansible"
  network_interface {
    network = "default"
    access_config {
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
    ports    = [80, 22]
  }
}