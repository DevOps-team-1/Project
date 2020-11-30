provider "google" {
  credentials = var.credentials
  project     = var.project
  region      = var.region
  zone        = var.zone
  user_project_override = true
}

resource "google_compute_instance" "my_jencins_instance" {
  name           = "my-jencins-instance"
  machine_type   = "e2-medium"
  can_ip_forward = false



  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20201014"
    }
  }
}
resource "google_compute_instance" "my_ansible_instance" {
  name           = "my-ansible-instance"
  machine_type   = "e2-medium"
  can_ip_forward = false
  metadata_startup_script = file("Ansible.sh")

  provisioner "file" {
  source = "Ansible"
  destination = "~/Ansible"

  connection {
    host = self.network_interface.0.access_config.0.nat_ip
    type = "ssh"
    user = var.user
    private_key = "id_rsa"
    agent = "false"
    }
  }

  provisioner "remote-exec" {
    connection {
      host = self.network_interface.0.access_config.0.nat_ip
      type = "ssh"
      user = var.user
      private_key = "id_rsa"
      agent = "false"
    }
    inline = [
      "cat '[LAMP]' Ansible/hosts",
//      "cat [self.network_interface.0.acat_ip]",
      "./Ansible.sh"
    ]
  }

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

resource "google_compute_instance_template" "my_lamp_instance" {
  name           = "my-instance-template"
  machine_type   = "e2-medium"
  can_ip_forward = false
  tags = ["foo", "bar"]

  disk {
    source_image = "ubuntu-2004-focal-v20201014"
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_target_pool" "my_target_pool" {
  name = "my-target-pool-2"
}

resource "google_compute_instance_group_manager" "my_group" {
  name = "my-igm"
  zone = var.zone

  version {
    instance_template  = google_compute_instance_template.my_lamp_instance.id
    name               = "primary"
  }

  target_pools       = [google_compute_target_pool.my_target_pool.id]
  base_instance_name = "lamp"
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
    ports    = [80]
  }
}

module "gce-lb-fr" {
  source       = "github.com/GoogleCloudPlatform/terraform-google-lb"
  region       = var.region
  name         = "group1-lb"
  service_port = "80"
  target_tags  = ["allow-lb-service"]
}


resource "google_compute_autoscaler" "autoscal" {
  name   = "my-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.my_group.id

  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "local_file" "Ansible" {
  content = templatefile("Ansible/hosts",
    {
      lamp_instances = google_compute_instance_template.my_lamp_instance.*.network_interface.0.access_config.0.nat_ip
      jencins_instance = google_compute_instance.my_jencins_instance.*.network_interface.0.access_config.0.nat_ip
    }
  )
  filename = "Ansible/hosts"
}