data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = coalescelist(
    var.azs,
    [
      data.aws_availability_zones.available.names[0],
      data.aws_availability_zones.available.names[1],
      data.aws_availability_zones.available.names[02]
    ]
  )
}