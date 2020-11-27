provider "google" {
  credentials = file("prefab-mountain-292413-296112-ac76d2510eff.json")
  project     = "prefab-mountain-292413-296112"
  region      = "us-central1"
  zone        = "us-central1-a"
  user_project_override = true
}

resource "google_compute_autoscaler" "autoscal" {
  name   = "my-autoscaler"
  zone   = "us-central1-f"
  target = google_compute_instance_group_manager.my_group.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}


resource "google_compute_instance_template" "my_instance" {
  name           = "my-instance-template"
  machine_type   = "e2-medium"
  can_ip_forward = false
  tags = ["foo", "bar"]
  metadata_startup_script = file("Ansible.sh")
  
  disk {
    source_image = data.google_compute_image.debian_9.id
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  metadata = {
    foo = "bar"
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
  zone = "us-central1-f"

  version {
    instance_template  = google_compute_instance_template.my_instance.id
    name               = "primary"
  }

  target_pools       = [google_compute_target_pool.my_target_pool.id]
  base_instance_name = "foobar"
}

data "google_compute_image" "debian_9" {
  family  = "debian-9"
  project = "debian-cloud"
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

//module "gce-lb-fr" {
//  source       = "github.com/GoogleCloudPlatform/terraform-google-lb"
//  region       = var.region
//  name         = "group1-lb"
//  service_port = "80"
//  target_tags  = ["allow-lb-service"]
//}

