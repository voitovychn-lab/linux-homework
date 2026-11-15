# Налаштування AWS
provider "aws" {
  region = "us-west-2"
}

# Модуль S3 та DynamoDB
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "nazar-voitovych-terraform-state-lesson-5"
  table_name  = "terraform-locks"
}

# Модуль VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]

  availability_zones = [
    "us-west-2a",
    "us-west-2b",
    "us-west-2c"
  ]

  vpc_name = "lesson-5-vpc"
}

# Модуль ECR
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = "lesson-7-ecr"
  scan_on_push = true
}


# Модуль EKS (Kubernetes)
module "eks" {
  source = "./modules/eks"

  cluster_name = "lesson-7-eks"
  subnet_ids   = module.vpc.private_subnets
}
