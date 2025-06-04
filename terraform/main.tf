provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source                = "./modules/vpc"
  project               = var.project
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  azs                   = var.azs
}
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project}-lambda-sg"
  description = "Allow Lambda VPC access"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-lambda-sg"
  }
}

module "s3" {
  source  = "./modules/s3"
  project = var.project
}

module "lambda" {
  source            = "./modules/lambda"
  project           = var.project
  lambda_zip_path   = "${path.module}/modules/lambda/ocr_processor.zip"
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = aws_security_group.lambda_sg.id
  bucket_name       = module.s3.bucket_name
  vpc_id            = module.vpc.vpc_id
}

module "api_gateway" {
  source               = "./modules/api_gateway"
  project              = var.project
  lambda_function_name = module.lambda.lambda_function_name
  lambda_invoke_arn    = module.lambda.lambda_function_arn
  region               = "us-east-1"
}

