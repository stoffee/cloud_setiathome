resource "google_compute_instance" "default" {
  name         = "${random_pet.server.id}-proj"
  machine_type = var.instance_type
  zone         = var.gcp_zone

  tags = ["mission", "prod"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    Mission = "Prod"
  }

  #metadata_startup_script = "echo hello_umm_hello > /test.txt"
  metadata_startup_script = <<SCRIPT
    sudo apt update && sudo apt install -y unzip jq boinc-client dnsutils
    sleep 3
    systemctl restart boinc-client
    sleep 30
    sudo boinccmd --project_attach http://www.worldcommunitygrid.org/ 0abc390da3c3b820dd884024d84d8cbf
    sleep 30
    systemctl restart boinc-client
    sleep 120
    sudo boinccmd --project http://www.worldcommunitygrid.org/ detach
    sudo boinccmd --project_attach http://www.worldcommunitygrid.org/ 0abc390da3c3b820dd884024d84d8cbf
  SCRIPT

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
