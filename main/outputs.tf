output "_00_00_server_fqdn" {
  value = module.build_services.server_fqdn
}

output "_01_00_s3_bucket_name" {
  value = module.build_services.s3_bucket_name
}

output "_01_01_s3_bucket_region" {
  value = module.build_services.s3_bucket_region
}

output "_01_02_s3_aws_access_key_id" {
  value = module.build_services.s3_aws_access_key_id
}

output "_01_03_s3_aws_secret_access_key" {
  value = module.build_services.s3_aws_secret_access_key
}

output "_01_04_s3_aws_role_arn" {
  value = module.build_services.s3_aws_role_arn
}

output "_03_01_nomad_server_cert" {
  value = module.build_services.nomad_server_cert
}

output "_03_02_nomad_server_key" {
  value = module.build_services.nomad_server_key
}

output "_03_03_nomad_ca" {
  value = module.build_services.nomad_ca
}

output "_03_04_nomad_asg_region" {
  value = data.aws_region.current.name #this is lazy
}

output "_03_05_nomad_aws_access_key_id" {
  value = module.build_services.nomad_aws_access_key_id
}

output "_03_06_nomad_aws_secret_key_id" {
  value = module.build_services.nomad_aws_secret_key_id
}

output "_03_07_nomad_aws_role_arn" {
  value = module.build_services.nomad_aws_role_arn
}

output "_03_08_nomad_asg_name" {
  value = module.build_services.nomad_asg_name
}


output "_04_01_vms_region" {
  value = data.aws_region.current.name
}

output "_04_02_vms_subnet" {
  value = module.build_services.vms_subnet
}

output "_04_03_vms_sg" {
  value = module.build_services.vms_sg
}

output "_04_04_vms_aws_access_key_id" {
  value = module.build_services.vms_aws_access_key_id
}

output "_04_05_vms_aws_secret_access_key" {
  value = module.build_services.vms_aws_secret_access_key
}

output "_04_06_vms_aws_role_arn" {
  value = module.build_services.vms_aws_role_arn
}

output "_99_01_server_subdomain" {
  value = var.server_subdomain
}

output "_99_02_r53_hosted_zone_domain" {
  value = var.r53_hosted_zone_domain
}

output "_99_04_owner" {
  value = var.owner
}

output "_99_05_team" {
  value = var.team
}

output "_99_06_source_repo" {
  value = var.source_repo
}