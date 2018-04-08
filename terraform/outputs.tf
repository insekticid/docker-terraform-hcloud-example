output "master_ips" {
  value = ["${hcloud_server.master.*.ipv4_address}"]
}
