
# Назва Kubernetes кластера
output "cluster_name" {
  description = "Назва EKS кластера"
  value       = aws_eks_cluster.main.name
}

# Адреса Kubernetes API
output "cluster_endpoint" {
  description = "Endpoint EKS кластера"
  value       = aws_eks_cluster.main.endpoint
}

# Сертифікат для підключення до кластера
output "cluster_certificate_authority" {
  description = "Сертифікат EKS кластера"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

# Назва групи робочих вузлів
output "node_group_name" {
  description = "Назва Node Group"
  value       = aws_eks_node_group.main.node_group_name
}
# ARN OIDC провайдера
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

# URL OIDC провайдера
output "oidc_provider_url" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}