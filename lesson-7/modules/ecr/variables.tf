variable "ecr_name" {
  description = "Назва репозиторію ECR"
  type        = string
}

variable "scan_on_push" {
  description = "Сканування образів під час завантаження"
  type        = bool
}