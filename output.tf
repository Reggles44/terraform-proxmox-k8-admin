output "k8_admin_ip" {
  value = resource.proxmox_vm_qemu.k8_admin.ssh_host
}

output "k8_join_command" {
  value = data.remote_file.k8_join_file.content
}
