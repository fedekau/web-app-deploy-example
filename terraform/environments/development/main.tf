provider "aws" {
  region = "us-east-1"
}

variable "environment" {
  default = "development"
}

module "network" {
  source  = "../../modules/network"

  environment = "${var.environment}"
}
