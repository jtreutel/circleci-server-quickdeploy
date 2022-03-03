module "external_lb_dns" {
    source = "git::https://github.com/jtreutel/circleci-server-tf-modules.git//modules/ext_lb_dns?ref=dev"

    server_fqdn            = data.terraform_remote_state.main.outputs._00_00_server_fqdn
    server_subdomain       = data.terraform_remote_state.main.outputs._99_01_server_subdomain
    r53_hosted_zone_domain = data.terraform_remote_state.main.outputs._99_02_r53_hosted_zone_domain

    owner = data.terraform_remote_state.main.outputs._99_04_owner
    team = data.terraform_remote_state.main.outputs._99_05_team
    source_repo = data.terraform_remote_state.main.outputs._99_06_source_repo

    circleci_server_k8s_namespace = var.circleci_server_k8s_namespace
    r53_ttl = var.r53_ttl
}