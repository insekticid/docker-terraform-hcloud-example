provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_ssh_key" "admin" {
  name       = "admin"
  public_key = "${file(var.ssh_public_key)}"
}

resource "hcloud_server" "rancher" {
  count       = "1"
  name        = "rancher"
  server_type = "cx11-ceph"
  image       = "ubuntu-16.04"
  ssh_keys    = ["${hcloud_ssh_key.admin.id}"]
  keep_disk   = "true"

  connection {
    private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = "DOCKER_VERSION=${var.docker_version} bash /root/bootstrap.sh"
  }
  
  provisioner "file" {
    source      = "scripts/rancher.sh"
    destination = "/root/rancher.sh"
  }

  provisioner "remote-exec" {
    inline = "RANCHER_VERSION=${var.rancher_version} bash /root/rancher.sh"
  }
  
  provisioner "file" {
    source      = "scripts/kubectl.sh"
    destination = "/root/kubectl.sh"
  }

  provisioner "remote-exec" {
    inline = "bash /root/kubectl.sh"
  }
  
  provisioner "file" {
    source      = "scripts/rancher_change_password.sh"
    destination = "/root/rancher_change_password.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "RANCHER_SERVER_ADDRESS=${hcloud_server.rancher.0.ipv4_address} RANCHER_PASSWORD=${var.rancher_password} bash /root/rancher_change_password.sh",
    ]
  }
}

resource "hcloud_server" "rancher-etcd-control-worker" {
  count       = "3"
  name        = "${count.index == 0 ? "gitlab" : "node${count.index}"}"
  server_type = "cx11"
  image       = "ubuntu-16.04"
  ssh_keys    = ["${hcloud_ssh_key.admin.id}"]
  
  depends_on = ["hcloud_server.rancher"]

  connection {
    private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = "DOCKER_VERSION=${var.docker_version} bash /root/bootstrap.sh"
  }

  provisioner "file" {
    source      = "scripts/rancher_agent_command.sh"
    destination = "/root/rancher_agent_command.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
        "RANCHER_SERVER_ADDRESS=${hcloud_server.rancher.0.ipv4_address} RANCHER_PASSWORD=${var.rancher_password} bash /root/rancher_agent_command.sh"
    ]
  }
    
  provisioner "file" {
    source      = "scripts/kubectl.sh"
    destination = "/root/kubectl.sh"
  }

  provisioner "remote-exec" {
    inline = "bash /root/kubectl.sh"
  }
}

