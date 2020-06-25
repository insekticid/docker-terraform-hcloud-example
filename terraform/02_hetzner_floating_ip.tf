locals {
  instance_id = hcloud_server.k8s[0].id
  instance_ip = hcloud_server.k8s[0].ipv4_address
}

resource "hcloud_floating_ip" "master" {
  type          = "ipv4"
  home_location = "fsn1"
  description   = "lb"
  server_id     = local.instance_id
  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "add_ip" {
  triggers = {
    instance_id = local.instance_id
  }

  connection {
    user        = "root"
    host        = local.instance_ip
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  # add floating IP
  # add floating IP
  provisioner "remote-exec" {
    inline = [
      "sudo echo 'iface eth0 inet static\n address ${hcloud_floating_ip.master.ip_address}/24\n' >> /etc/network/interfaces",
      "sudo ifdown eth0 && sudo ifup eth0",
    ]
  }
}

resource "null_resource" "assign_server_ip" {
  triggers = {
    instance_id = local.instance_id
  }

  provisioner "local-exec" {
    command = <<CMD
          curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer ${var.hcloud_token}" -d '{"server":"${local.instance_id}"}' https://api.hetzner.cloud/v1/floating_ips/${hcloud_floating_ip.master.id}/actions/assign
      
CMD

  }
}

