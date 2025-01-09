output "k8_admin_ip" {
  value = resource.proxmox_vm_qemu.k8_admin.ssh_host
}

output "k8_join" {
  value = resource.ssh_resource.k8_init.result
}
