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
 // metadata = {
 //  ssh-keys = "pingvin:${file("id_rsa.pub")}"
// }
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20201014"
    }
  }

  metadata_startup_script ="sudo apt-get update; sudo apt install software-properties-common; sudo apt-add-repository --yes --update ppa:ansible/ansible; sudo apt install ansible"
  network_interface {
    network = "default"
    access_config {
    }
  }
}