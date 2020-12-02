provider "google-beta" {
  credentials = file(var.credentials)
  project     = "prefab-mountain-292413-296112"
  region      = var.region
  zone        = var.zone
  user_project_override = true


}
resource "google_compute_machine_image" "ubuntuimage" {
  provider = google-beta
  name = "ubuntuimage"
  source_instance = "https://www.googleapis.com/compute/v1/projects/prefab-mountain-292413-296112/zones/us-central1-a/instances/ubuntuconfig"
}


