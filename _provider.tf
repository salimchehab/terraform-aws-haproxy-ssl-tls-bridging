provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.0"

  assume_role {
    role_arn     = var.role_arn
    session_name = var.session_name
  }
}
