provider "aws" {
  region = var.region

  default_tags {
    tags = {
      team   = var.team
      owner  = var.owner
      source = var.source_repo
    }
  }
}

provider "kubernetes" {
  config_path = "../main/kubeconfig"
}