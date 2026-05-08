output "instances" {
  description = "Instancias creadas y sus floating IPs."
  value = {
    for name, vm in module.vm :
    name => {
      id          = vm.instance_id
      subject     = vm.subject
      floating_ip = try(openstack_networking_floatingip_v2.vm[name].address, try(var.instances[name].floating_ip, null))
    }
  }
}
