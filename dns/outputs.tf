output "_02_00_output_processor_hostname" {
  value = module.external_lb_dns.op_hostname
}

output "_03_00_nomad_hostname" {
  value = module.external_lb_dns.nomad_hostname
}

output "_04_00_vms_hostname" {
  value = module.external_lb_dns.vms_hostname
}