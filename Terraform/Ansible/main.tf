
provider "google" {
  credentials = file("prefab-mountain-292413-8ee3c7307748.json")
  project     = "prefab-mountain-292413"
  region      = "us-central1"
  zone        = "us-central1-a"
  user_project_override = true
}



resource "google_compute_instance" "test_instans" {
  name = "terraform${count.index}"
  count = 2
  machine_type = "e2-medium"
//  metadata = {
//    ssh-keys = "samirshahubs2:${file("id_rsa.pub")}"
//  }
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20201014"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
//  provisioner "file" {
//    source      = "lamp.sh"
//    destination = "~/lamp.sh"
//
//    connection {
//        type = "ssh"
//        user = "samirus"
//        private_key = file("id_rsa")
//        host = self.network_interface.0.access_config.0.nat_ip
//    }
//  }

  provisioner "remote-exec" {
    inline = [
          "echo ${self.network_interface.0.access_config.0.nat_ip} >> ~/pub_ip_address.txt",
//          "chmod +x lamp.sh",
//          "sudo bash lamp.sh"
      ]
    connection {
          type = "ssh"
          user = "samirus"
          private_key = file("id_rsa")
          host = self.network_interface.0.access_config.0.nat_ip
      }
  }
}

resource "google_compute_firewall" "default" {
  name    = "terraformfirewall"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["80", "9090", "22"]
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-vpc-145"
  auto_create_subnetworks = "true"
}

output "ip" {
  value = google_compute_instance.test_instans.*.network_interface.0.access_config.0.nat_ip
}