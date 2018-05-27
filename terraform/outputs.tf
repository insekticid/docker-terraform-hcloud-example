output "rancher_ips" {
  value = ["${hcloud_server.k8s.*.ipv4_address}"]
}
