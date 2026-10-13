terraform {
    required_providers {
        proxmox = {
            source = "bpg/proxmox"
            version = "0.112.0"
        }
    }
}

provider "proxmox" {
    endpoint = var.proxmox_endpoint
    api_token = var.proxmox_api_token
    insecure = true
    ssh {
        username = "root"
        private_key = file(var.proxmox_ve_ssh_private_key)
        node {
            name = "server-1"
            address = "10.127.0.2"
        }
    }
}

variable "pve_nodes" {
    type = list(string)
    default = ["server-1", "server-3", "server-4"]
}

resource "proxmox_download_file" "ubuntu_cloud_image" {
    for_each = toset(var.pve_nodes)
    content_type = "iso"
    datastore_id = "local"
    node_name = each.key
    url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_vm" "benedict_lab" {
    count = length(var.pve_nodes)
    
    node_name = var.pve_nodes[count.index]
    name = "docker-swarm-${count.index + 1}"

    cpu {
        cores = 2
    }

    memory {
        dedicated = 6144
        floating = 6144
    }

    disk {
        datastore_id = "local-lvm"
        file_id = proxmox_download_file.ubuntu_cloud_image[var.pve_nodes[count.index]].id
        interface = "scsi0"
        size = 50
    }

    network_device {
        bridge = "vmbr0"
    }

    # should be true if qemu agent is not installed / enabled on the VM
    stop_on_destroy = true

    initialization {
        ip_config {
          ipv4 {
            address = "10.127.0.${count.index + 8}/24"
            gateway = "10.127.0.1"
          }
        }
        user_account {
            username = "ubuntu"
            keys = [var.ssh_key]
        }
    }
}