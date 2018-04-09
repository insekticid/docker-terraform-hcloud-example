output "rancher_ips" {
  value = ["${hcloud_server.rancher.*.ipv4_address}"]
}
