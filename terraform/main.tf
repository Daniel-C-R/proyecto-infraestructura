data "openstack_images_image_v2" "base_image" {
  name = var.image_name
}

data "openstack_networking_network_v2" "tenant_network" {
  name = var.network_name
}

resource "openstack_compute_keypair_v2" "admin" {
  name       = var.keypair_name
  public_key = trimspace(file(pathexpand(var.public_key_path)))
}

resource "openstack_networking_secgroup_v2" "ssh" {
  name        = "ssh-ingress"
  description = "Permitir acceso SSH para la administracion"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.ssh.id
}

locals {
  instances_with_created_fip = var.create_floating_ips ? var.instances : {}
  instances_with_existing_fip = {
    for name, instance in var.instances :
    name => instance
    if try(instance.floating_ip, null) != null
  }
}

module "vm" {
  source   = "./modules/openstack_vm"
  for_each = var.instances

  name                = each.key
  image_id            = data.openstack_images_image_v2.base_image.id
  flavor_name         = each.value.flavor_name
  network_name        = data.openstack_networking_network_v2.tenant_network.name
  key_pair_name       = openstack_compute_keypair_v2.admin.name
  security_groups     = concat(var.common_security_group_names, [openstack_networking_secgroup_v2.ssh.name], each.value.extra_security_groups)
  admin_user          = var.admin_user
  public_key          = trimspace(file(pathexpand(var.public_key_path)))
  timezone            = var.timezone
  subject             = each.value.subject
  student_user        = each.value.student_user
  student_public_keys = each.value.student_public_keys
  private_key_path    = pathexpand(var.private_key_path)
  instance_metadata   = each.value.metadata
}

data "openstack_networking_port_v2" "vm_port" {
  for_each   = module.vm
  device_id  = each.value.instance_id
  network_id = data.openstack_networking_network_v2.tenant_network.id
}

resource "openstack_networking_floatingip_v2" "vm" {
  for_each = local.instances_with_created_fip
  pool     = var.external_network_name
}

resource "openstack_networking_floatingip_associate_v2" "vm" {
  for_each    = merge(local.instances_with_created_fip, local.instances_with_existing_fip)
  port_id     = data.openstack_networking_port_v2.vm_port[each.key].id
  floating_ip = var.create_floating_ips ? openstack_networking_floatingip_v2.vm[each.key].address : each.value.floating_ip
}
