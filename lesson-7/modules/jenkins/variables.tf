variable "cluster_name" {
  description = "Назва Kubernetes кластера"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN OIDC провайдера EKS"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL OIDC провайдера EKS"
  type        = string
}