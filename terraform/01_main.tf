provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "admin" {
  name       = var.ssh_key_name
  public_key = file(var.ssh_public_key)
}

resource "hcloud_server" "k8s" {
  count       = "1"
  name        = "node-0"
  server_type = "cx11-ceph"
  image       = "ubuntu-18.04"
  location    = "fsn1"
  ssh_keys    = [hcloud_ssh_key.admin.id]

  connection {
    host        = self.ipv4_address
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["DOCKER_VERSION=${var.docker_version}", "bash", "/root/bootstrap.sh"]
  }

  provisioner "file" {
    source      = "scripts/rancher.sh"
    destination = "/root/rancher.sh"
  }

  provisioner "remote-exec" {
    inline = ["RANCHER_VERSION=${var.rancher_version}", "ACME_DOMAIN=${var.acme_domain}", "bash",  "/root/rancher.sh"]
  }

  provisioner "file" {
    source      = "scripts/kubectl.sh"
    destination = "/root/kubectl.sh"
  }

  provisioner "remote-exec" {
    inline = ["bash", "/root/kubectl.sh"]
  }

  provisioner "file" {
    source      = "scripts/rancher_change_password.sh"
    destination = "/root/rancher_change_password.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "RANCHER_SERVER_ADDRESS=${hcloud_server.k8s[0].ipv4_address}", "RANCHER_PASSWORD=${var.rancher_password}", "RANCHER_KUBERNETES_VERSION=${var.rancher_kubernetes_version}", "RANCHER_CLUSTER_NAME=${var.rancher_cluster_name}", "bash", "/root/rancher_change_password.sh"
    ]
  }
}

resource "hcloud_server" "k8s-etcd-control-worker" {
  count       = "3"
  name        = count.index == 0 ? "gitlab" : "node-${count.index}"
  server_type = "cx11-ceph"
  image       = "ubuntu-18.04"
  location    = "fsn1"
  ssh_keys    = [hcloud_ssh_key.admin.id]

  depends_on = [hcloud_server.k8s]

  connection {
    host        = self.ipv4_address
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["DOCKER_VERSION=${var.docker_version}", "bash", "/root/bootstrap.sh"]
  }

  provisioner "file" {
    source      = "scripts/rancher_agent_command.sh"
    destination = "/root/rancher_agent_command.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "RANCHER_SERVER_ADDRESS=${hcloud_server.k8s[0].ipv4_address}", "RANCHER_PASSWORD=${var.rancher_password}", "bash", "/root/rancher_agent_command.sh"
    ]
  }

  provisioner "file" {
    source      = "scripts/kubectl.sh"
    destination = "/root/kubectl.sh"
  }

  provisioner "remote-exec" {
    inline = ["bash", "/root/kubectl.sh"]
  }
}

