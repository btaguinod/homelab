variable "ssh_key" {
	default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwMXyQXAP6Q0VDdbOsyNGIrGBumfSJZyppXy9vaykrb homelab_proxmox"
}
	
variable "template_name" {
    default = "ubuntu-2604-template"
}

variable "nic_name" {
    default = "vmbr0"
}

variable "proxmox_endpoint" {
    default = "https://10.127.0.2:8006/"
}

variable "proxmox_api_token" {
}

variable "proxmox_ve_ssh_private_key" {
}

