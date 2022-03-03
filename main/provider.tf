provider "aws" {
  region  = var.region
  profile = "default"

  default_tags {
    tags = {
      team   = var.team
      owner  = var.owner
      source = var.source_repo
    }
  }
}