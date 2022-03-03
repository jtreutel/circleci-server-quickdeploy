#----------------
# General
#----------------
variable "region" {}

# Tags info
variable "team" {}
variable "owner" {}
variable "source_repo" {}

variable "circleci_server_k8s_namespace" {
  default = "circleci-server"
}

variable "r53_ttl" {
  default = 1 #low ttl for testing purposes
}