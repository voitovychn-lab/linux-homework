# ECR — адреса Docker-репозиторію
output "ecr_repository_url" {
  description = "URL репозиторію Django в ECR"
  value       = module.ecr.repository_url
}

# EKS — назва Kubernetes-кластера
output "eks_cluster_name" {
  description = "Назва EKS кластера"
  value       = module.eks.cluster_name
}

# EKS — адреса Kubernetes API
output "eks_cluster_endpoint" {
  description = "Endpoint EKS кластера"
  value       = module.eks.cluster_endpoint
}

# EKS — група робочих вузлів
output "eks_node_group_name" {
  description = "Назва Node Group"
  value       = module.eks.node_group_name
}

# VPC — ID підмереж із ДЗ №5
output "private_subnets" {
  description = "Приватні підмережі з попереднього завдання"
  value       = data.terraform_remote_state.lesson5.outputs.private_subnets
}