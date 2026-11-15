
provider "aws" {
  region = "us-west-2"
}

# Використання VPC з домашнього завдання №5
data "terraform_remote_state" "lesson5" {
  backend = "s3"

  config = {
    bucket = "nazar-voitovych-terraform-state-lesson-5"
    key    = "lesson-5/terraform.tfstate"
    region = "us-west-2"
  }
}

# Репозиторій Docker-образів
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = "lesson-7-ecr"
  scan_on_push = true
}

# Kubernetes EKS
module "eks" {
  source = "./modules/eks"

  cluster_name = "lesson-7-eks"

  # Використовуємо приватні підмережі з ДЗ №5
  subnet_ids = data.terraform_remote_state.lesson5.outputs.private_subnets
}
