output "k8_admin_ip" {
  value = resource.k8_admin.ssh_host
}

output "k8_join" {
  value = resource.k8_init.result
}
