#-------------------------------------------------------------------------------
# VPC and Networking Resources
#-------------------------------------------------------------------------------

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"


  name = var.resource_prefix
  cidr = var.vpc_cidr_block

  azs             = local.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  enable_dns_hostnames = true

  # This allows EKS to figure out which subnets are public/private
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.resource_prefix}-eks" = "shared"
    "kubernetes.io/role/internal-elb"                  = "1"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.resource_prefix}-eks" = "shared"
    "kubernetes.io/role/elb"                           = "1"
  }
}

resource "aws_security_group" "eks_cluster_nodes" {
  name        = "${var.resource_prefix}-k8s-nodes-sg"
  description = "SG for ${var.resource_prefix} k8s nodes"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.resource_prefix}-eks-nodes-sg"
  }
}
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  to_port           = 22
  from_port         = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_whitelist
  security_group_id = aws_security_group.eks_cluster_nodes.id
}
resource "aws_security_group_rule" "allow_all_self" {
  type              = "ingress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_cluster_nodes.id
}
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_nodes.id
}

#-------------------------------------------------------------------------------
# SSH Key Resources
#-------------------------------------------------------------------------------

resource "random_string" "key_suffix" {
  length  = 8
  special = false
}

module "ssh_key" {
  source   = "git::https://github.com/jtreutel/terraform-ec2-keypair.git"
  key_name = "jennings-server-migration-${random_string.key_suffix.result}"
}
resource "local_file" "ssh_key_private" {
  content         = module.ssh_key.private_key
  filename        = "${path.module}/../sshkeys/ssh_key.pem"
  file_permission = "0600"
}
resource "local_file" "ssh_key_public" {
  content  = module.ssh_key.public_key
  filename = "${path.module}/../sshkeys/ssh_key.pub"
}


#-------------------------------------------------------------------------------
# EKS Cluster and Associated Resources
#-------------------------------------------------------------------------------

module "eks_cluster" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = "${var.resource_prefix}-eks"
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true #Sets up OIDC provider for EKS

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)


  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks_cluster.arn
    resources        = ["secrets"]
  }]

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    vpc_security_group_ids = [aws_security_group.eks_cluster_nodes.id]
  }

  eks_managed_node_groups = {
    "${var.resource_prefix}" = {
      min_size     = 4
      max_size     = 10
      desired_size = 4

      disk_size = 100

      key_name = module.ssh_key.key_name

      instance_types = var.eks_instance_types
      labels = {
        Environment = "demo"
      }
      taints = {}
    }
  }
}


resource "aws_kms_key" "eks_cluster" {

  description             = "For encrypting EKS secrets used by ${var.resource_prefix} EKS cluster."
  deletion_window_in_days = 14

  tags = {
    Name = "${var.resource_prefix}-kms-key"
  }
}


#Generate kubeconfig file
resource "local_file" "eks_cluster" {
  filename = "${path.root}/kubeconfig"
  content = templatefile(
    "${path.module}/templates/kubeconfig.tpl",
    {
      cluster_name     = module.eks_cluster.cluster_id,
      cluster_endpoint = module.eks_cluster.cluster_endpoint,
      ca_data          = module.eks_cluster.cluster_certificate_authority_data,
      region           = data.aws_region.current.name
      aws_profile      = var.profile
    }
  )
}



# Build Services

module "build_services" {
  source = "git::https://github.com/jtreutel/circleci-server-tf-modules.git//modules/build_services?ref=dev"

  resource_prefix           = var.resource_prefix
  server_fqdn               = "${var.server_subdomain}.${var.r53_hosted_zone_domain}"
  public_subnets            = module.vpc.public_subnets
  eks_cluster_name          = module.eks_cluster.cluster_id
  nomadc_instance_type      = var.nomadc_instance_type
  nomadc_vpc                = module.vpc.vpc_id
  nomadc_subnet             = module.vpc.public_subnets[0]
  nomadc_ssh_authorized_key = module.ssh_key.public_key_openssh
  nomadc_desired_capacity   = var.nomadc_desired_capacity
  nomad_autoscaler_enabled  = var.nomad_autoscaler_enabled
  vms_subnet                = module.vpc.public_subnets[1]
  vms_public                = var.vms_public

  use_iam_role_for_nomad_autoscaler = var.use_iam_role_for_nomad_autoscaler
  use_iam_role_for_s3_access        = var.use_iam_role_for_s3_access
  use_iam_role_for_vm_service       = var.use_iam_role_for_vm_service

  eks_oidc_provider_arn       = module.eks_cluster.oidc_provider_arn
  eks_cluster_oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url

  eks_subnet_count = length(
    concat(
      var.public_subnets,
      var.private_subnets
    )
  )

  depends_on = [
    module.eks_cluster,
    module.ssh_key
  ]
}