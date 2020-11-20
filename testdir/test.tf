resource "google_compute_autoscaler" "scala" {
  name = "myautoscaler"
  project = "prefab-mountain-292413-296112"
  zone = "us-central1-a"
  target = google_compute_instance_group_manager.scala.self_link

  autoscaling_policy {
  max_replicas = 5
  min_replicas = 2
  cooldown_period = 60

    cpu_utilization {
    target = 0.5
    }
  }
}

resource "google_compute_instance_template" "scala" {
  name = "my-instance-template"
  machine_type = "e2-medium"
  can_ip_forward = false
  project = "prefab-mountain-292413-296112"
  tags = ["foo", "bar", "allow-lb-service"]

  disk {
    source_image = data.google_compute_image.ubuntu.self_link
}
  network_interface {
    network = google_compute_network.vpc_network.name
}
  metadata = {
    foo = "bar"
}
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
}
}
resource "google_compute_target_pool" "scala" {
  name = "my-target-pool"
  project = "prefab-mountain-292413-296112"
  region = "us-central1"
}

resource "google_compute_instance_group_manager" "scala" {
  name = "my-igm"
  zone = "us-central1-c"
  project = "prefab-mountain-292413-296112"
  version {
    instance_template = google_compute_instance_template.scala.self_link
    name = "primary"
}

target_pools = [google_compute_target_pool.scala.self_link]
base_instance_name = "terraform"
}

data "google_compute_image" "ubuntu" {
  family = "ubuntu"
  project = "ubuntu-cloud"
}

//module "lb" {
//  source = "GoogleCloudPlatform/lb/google"
//  version = "2.2.0"
//  region = "us-central1"
//  name = "load-balancer"
//  service_port = 80
//  target_tags = [
//    "my-target-pool"]
//  network = google_compute_network.vpc_network.name
//}
