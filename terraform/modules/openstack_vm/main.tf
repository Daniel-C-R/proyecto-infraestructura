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

}
