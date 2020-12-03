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
////// file edit

resource "local_file" "hosts_cfg" {
  content = templatefile(file("hosts"), { lamp_instances = google_compute_instance_template.my_lamp_instance.network_interface[0].access_config[0].nat_ip }                             )
  filename = "hosts_cfg"
}

//////////another method

//data "template_file" "dev_hosts" {
//  template = "${file("hosts")}"
//  vars {
//    api_public = "${google_compute_instance_template.my_lamp_instance.network_interface[0].access_config[0].nat_ip}"
//  }
//}
//
//resource "null_resource" "dev-hosts" {
//  triggers {
//    template_rendered = "${data.template_file.dev_hosts.rendered}"
//  }
//  provisioner "local-exec" {
//    command = "echo '${data.template_file.dev_hosts.rendered}' > hosts"
//  }
//}




//////////another method

//data  "template_file" "k8s" {
//    template = "${file("hosts")}"
//    vars {
//        k8s_master_name = "${join("\n", google_compute_instance_template.my_lamp_instance.network_interface[0].access_config[0].nat_ip)}"
//    }
//}
//
//resource "local_file" "k8s_file" {
//  content  = "${data.template_file.k8s.rendered}"
//  filename = "hosts"
//}