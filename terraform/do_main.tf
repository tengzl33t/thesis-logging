terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    ansible = {
      version = "~> 1.0.0"
      source  = "ansible/ansible"
    }
  }
}

variable "do_token" {}
variable "do_private_key" {}
variable "do_public_key" {}

variable "loki_port" {}
variable "loki_image" {}

variable "vector_port" {}
variable "vector_image" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "def_pk" {
  name       = "DO Terraform"
  public_key = file(var.do_public_key)
}


resource "digitalocean_droplet" "vector" {
  image    = "centos-stream-9-x64"
  name     = "vector.company.internal"
  region   = "lon1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.def_pk.fingerprint]


  provisioner "remote-exec"{
    inline = [
      "echo Vector server is running!",
    ]

    connection {
      host        = self.ipv4_address
      user        = "root"
      type        = "ssh"
      private_key = file(var.do_private_key)
      timeout     = "2m"
    }
  }

}

resource "digitalocean_droplet" "loki" {
  image    = "centos-stream-9-x64"
  name     = "loki.company.internal"
  region   = "lon1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.def_pk.fingerprint]


  provisioner "remote-exec"{
    inline = [
      "echo Loki server is running!",
    ]

    connection {
      host        = self.ipv4_address
      user        = "root"
      type        = "ssh"
      private_key = file(var.do_private_key)
      timeout     = "2m"
    }
  }

}

resource "ansible_host" "vector-0" {
  name   = digitalocean_droplet.vector.name
  groups = ["vector"]
  variables = {
    ansible_host = digitalocean_droplet.vector.ipv4_address,
    ansible_user = "root",
    ansible_ssh_private_key_file = var.do_private_key,
    ansible_ssh_extra_args = "-o StrictHostKeyChecking=no"
  }
}

resource "ansible_host" "loki-0" {
  name   = digitalocean_droplet.loki.name
  groups = ["loki"]
  variables = {
    ansible_host = digitalocean_droplet.loki.ipv4_address,
    ansible_user = "root",
    ansible_ssh_private_key_file = var.do_private_key,
    ansible_ssh_extra_args = "-o StrictHostKeyChecking=no"
  }
}

resource "ansible_group" "vector" {
  name      = "vector"
  variables = {
    vector_port = var.vector_port,
    loki_port = var.loki_port,
    vector_image = var.vector_image
  }
}

resource "ansible_group" "loki" {
  name      = "loki"
  variables = {
    loki_port = var.loki_port,
    loki_image = var.loki_image
  }
}
