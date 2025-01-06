terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
    opnsense = {
      version = "0.11.0"
      source  = "browningluke/opnsense"
    }
  }
}

provider "opnsense" {
  uri        = "192.168.1.1"
  api_key    = var.opnsense_key
  api_secret = var.opnsense_secret
}

provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_api_token_id     = var.proxmox_user
  pm_api_token_secret = var.proxmox_password
  pm_tls_insecure     = true
}

resource "opnsense_firewall_nat" "k8_port_forwarding" {
  enabled = true

  interface = "wan"
  protocol  = "UDP"

  source = {
    net = "wan"
  }

  destination = {
    net  = var.ip_address
    port = "2456"
  }

  target = {
    ip   = "wanip"
    port = "http"
  }

  log         = true
  description = "k8"
}

resource "proxmox_vm_qemu" "k8-admin" {
  name             = "k8-admin"
  desc             = "K8 Admin"
  count            = 1
  vmid             = 103
  clone            = "debian"
  full_clone       = true
  cores            = 4
  memory           = 4096
  target_node      = var.proxmox_node
  agent            = 1
  boot             = "order=scsi0"
  scsihw           = "virtio-scsi-single"
  vm_state         = "running"
  automatic_reboot = true

  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "16G"
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 1
    bridge = "vmbr0"
    model  = "virtio"
  }

  os_type       = "cloud-init"
  cicustom      = "user=local:snippets/debian.yml"
  ipconfig0     = "ip=dhcp"
  ipconfig1     = "ip=dhcp"
  agent_timeout = 120

  connection {
    type        = "ssh"
    user        = "debian"
    private_key = file("~/.ssh/id_rsa")
    host        = self.ssh_host
    port        = self.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "sudo systemctl enable --now kubelet",
    ]
  }
}

