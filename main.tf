terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
    macaddress = {
      version = "0.3.2"
      source  = "ivoronin/macaddress"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_api_token_id     = var.proxmox_user
  pm_api_token_secret = var.proxmox_password
  pm_tls_insecure     = true
}

resource "macaddress" "k8_admin" {}

resource "proxmox_vm_qemu" "k8-admin" {
  depends_on = [
    macaddress.k8_admin,
  ]

  name             = "k8-admin"
  desc             = "K8 Admin"
  count            = 1
  vmid             = var.vmid
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
    id      = 1
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = macaddress.k8_admin.address
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
      "cloud-init status --wait"
    ]
  }
}

