# Домашнє завдання №7 — Вивчення Helm

Войтович Назар

У цьому проєкті описано інфраструктуру AWS за допомогою Terraform та налаштовано Helm-чарт для Django-застосунку в Kubernetes.

Для роботи використано модулі з попереднього завдання та додано модуль EKS.

Регіон AWS - us-west-2.

## Структура проєкту

- main.tf - підключення модулів і налаштування AWS.
- backend.tf - налаштування збереження стейту в S3.
- outputs.tf - виведення результатів.
- modules/s3-backend - S3-бакет і таблиця DynamoDB.
- modules/vpc - мережа, підмережі, шлюзи та маршрути.
- modules/ecr - репозиторій для Docker-образів.
- modules/eks - кластер Kubernetes та робочі вузли.
- charts/django-app - Helm-чарт для Django.

## Опис модулів

### vpc

Створює VPC із трьома публічними та трьома приватними підмережами. Налаштовано Internet Gateway, NAT Gateway та таблиці маршрутизації.

### eks

Створює кластер Kubernetes в AWS EKS.

Для робочих вузлів використано EC2 t3.medium. Налаштовано групу вузлів із двома екземплярами та можливістю масштабування до трьох.

### ecr

Створює репозиторій lesson-7-ecr для Docker-образів Django. Увімкнено сканування образів під час завантаження.

### s3-backend

Налаштовує S3-бакет і таблицю DynamoDB для збереження та блокування стейту Terraform.

## Helm-чарт

У папці charts/django-app створено Helm-чарт, який містить:

- Deployment - запуск Django-застосунку.
- Service - доступ через LoadBalancer.
- ConfigMap - змінні середовища Django.
- HPA - автоматичне масштабування від 2 до 6 подів при навантаженні CPU 70%.
- values.yaml - основні налаштування застосунку.

## Підготовка

Для роботи потрібні Terraform, AWS CLI, Docker, kubectl та Helm.

Необхідно налаштувати доступ до AWS, підготувати S3-бакет і таблицю DynamoDB для backend.

Команди Terraform виконуються з папки lesson-7.

## Запуск Terraform

Ініціалізація та перевірка:

```bash
terraform init
terraform validate
```

Перегляд змін та створення ресурсів:

```bash
terraform plan
terraform apply
```

Після створення кластера налаштувати доступ до Kubernetes:

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
```

## Запуск Helm

Спочатку потрібно зібрати Docker-образ Django та завантажити його до ECR. Також необхідно налаштувати підключення до PostgreSQL.

З папки lesson-7 отримати адресу ECR:

```bash
terraform output -raw ecr_repository_url
```

Встановити Helm-чарт, підставивши отриману адресу ECR та адресу PostgreSQL:

```bash
helm install my-django ./charts/django-app \
  --set image.repository=АДРЕСА_ECR \
  --set config.POSTGRES_HOST=АДРЕСА_POSTGRESQL
```

Перевірка ресурсів Kubernetes:

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

## Перевірка

Перевірено форматування та конфігурацію Terraform:

```bash
terraform fmt -recursive -check
terraform init -backend=false
terraform validate
```

Перевірено Helm-чарт:

```bash
helm lint ./charts/django-app --set image.repository=example.com/lesson-7-ecr
helm template my-django ./charts/django-app --set image.repository=example.com/lesson-7-ecr
```

Перевірки завершилися успішно.

## Висновок

У ході виконання домашнього завдання підготовлено Terraform-конфігурацію для AWS EKS та ECR, а також Helm-чарт для Django-застосунку. Налаштовано Kubernetes Deployment, Service, ConfigMap і HPA для автоматичного масштабування.