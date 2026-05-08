terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

data "openstack_compute_flavor_v2" "selected" {
  name = var.flavor_name
}

resource "openstack_compute_instance_v2" "this" {
  name            = var.name
  image_id        = var.image_id
  flavor_id       = data.openstack_compute_flavor_v2.selected.flavor_id
  key_pair        = var.key_pair_name
  security_groups = distinct(var.security_groups)

  metadata = merge(var.instance_metadata, {
    subject                      = var.subject
    ansible_user                 = var.admin_user
    ansible_ssh_private_key_file = var.private_key_path
    managed_by                   = "terraform"
  })

  network {
    name = var.network_name
  }

  user_data = <<-EOF
    #cloud-config
    users:
      - name: ${var.admin_user}
        lock_passwd: true
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ${var.public_key}
    package_update: true
    packages:
      - python3
      - qemu-guest-agent
    ssh_pwauth: false
    disable_root: true
    timezone: ${var.timezone}
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl restart qemu-guest-agent
  EOF
}
