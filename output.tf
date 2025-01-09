output "k8_admin_ip" {
  value = proxmox_vm_qemu.k8_admin.ssh_host
}

output "k8_join" {
  value = ssh_resource.k8_init.result
}
