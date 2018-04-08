provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_ssh_key" "admin" {
  name       = "admin"
  public_key = "${file(var.ssh_public_key)}"
}

resource "hcloud_server" "master" {
  count       = "1"
  name        = "master"
  server_type = "cx11-ceph"
  image       = "ubuntu-16.04"
  ssh_keys    = ["${hcloud_ssh_key.admin.id}"]

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
}
