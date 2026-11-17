
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
# Jenkins
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}
data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}
# Argo CD
module "argo_cd" {
  source = "./modules/argo_cd"

  git_repo_url = "https://github.com/voitovychn-lab/linux-homework.git"
}
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  token                  = data.aws_eks_cluster_auth.main.token
}