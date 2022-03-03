#----------------
# General
#----------------
variable "resource_prefix" {}
variable "region" {}

# Tags info
variable "team" {}
variable "owner" {}
variable "source_repo" {}

#Used for generating kubeconfig.  
#Assumes that AWS profile used for TF will be the same as the one used to interact with cluster via kubectl.
variable "profile" {
  type    = string
  default = "default"
}

#----------------
# VPC & Networking
#----------------

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# If left blank, the first three AZs in the current region will be used
variable "azs" {
  default = []
}

#IP addresses from which SSH traffic is allowed to EKS nodes
variable "ssh_whitelist" {
  default = []
}

variable "eks_instance_types" {
  default = ["m5.xlarge"]
}

variable "r53_hosted_zone_domain" {} #e.g. "foobar.example.com"
variable "server_subdomain" {
  default = "" #e.g. "server3" to point to server3.foobar.example.com; can be left blank to simply use the hosted zone domain root
}
variable "nomadc_instance_type" {
  default = "t3a.2xlarge"
}

variable "vms_public" {
  default = false
}

#must be >= 1
variable "nomadc_desired_capacity" {
}

variable "nomad_autoscaler_enabled" {
  type    = bool
  default = false
}

variable "use_iam_role_for_nomad_autoscaler" {}
variable "use_iam_role_for_s3_access" {}
variable "use_iam_role_for_vm_service" {} 