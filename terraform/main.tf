terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-1"
}


module "users" {

  source                           = "./users"
  db_password                      = var.db_password
  db_username                      = var.db_username
  db_name                          = var.db_name
  db_port                          = var.db_port
  create_user_lambda_function_name = var.create_user_lambda_function_name
  create_user_lambda_zip_filename  = var.create_user_lambda_zip_filename
  get_user_lambda_function_name    = var.get_user_lambda_function_name
  get_user_lambda_zip_filename     = var.get_user_lambda_zip_filename
  vpc_name                         = var.vpc_name
  cidr_block                       = var.cidr_block
  private_subnet_cidrs             = var.private_subnet_cidrs
  azs                              = var.azs


}
