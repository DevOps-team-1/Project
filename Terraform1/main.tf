provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
  zone        = var.zone
  user_project_override = true


}

resource "google_compute_instance" "UbuntuConfig" {
  name = "ubuntuconfig"
  machine_type = "e2-medium"


  provisioner "local-exec" {
    command = " echo [LAMP] > hosts ;echo  ansible_host=${ google_compute_instance.UbuntuConfig.network_interface.0.access_config.0.nat_ip }  >> hosts ; echo [LAMP:vars] >> hosts ; echo ansible_user=ansible >> hosts"
  }




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
  name = "terraformfirewall"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = [80,22]
  }
}


//resource "local_file" "ip_address" {
//    content  = google_compute_instance.UbuntuConfig.network_interface.0.access_config.0.nat_ip
//    filename = "ip_address.txt"
//}

