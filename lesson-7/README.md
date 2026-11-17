# Домашнє завдання №7–9 — Helm, Jenkins CI та Argo CD

**Войтович Назар**

У цьому проєкті описано інфраструктуру AWS за допомогою Terraform, налаштовано Helm-чарт для Django-застосунку в Kubernetes та реалізовано процес CI/CD із використанням Jenkins і Argo CD.

Для роботи використано модулі з попередніх домашніх завдань, додано модулі Jenkins та Argo CD.

Регіон AWS — `us-west-2`.

## Структура проєкту

- `main.tf` — підключення модулів і налаштування провайдерів AWS, Helm та Kubernetes.
- `backend.tf` — налаштування збереження Terraform state в S3.
- `outputs.tf` — виведення результатів Terraform.
- `modules/s3-backend` — S3-бакет і таблиця DynamoDB.
- `modules/vpc` — мережа, підмережі, шлюзи та маршрути.
- `modules/ecr` — репозиторій Docker-образів.
- `modules/eks` — Kubernetes-кластер EKS, робочі вузли та OIDC-провайдер.
- `modules/jenkins` — встановлення Jenkins через Helm.
- `modules/argo_cd` — встановлення Argo CD та опис GitOps Application.
- `charts/django-app` — Helm-чарт Django та PostgreSQL.
- `docker/django` — Dockerfile і файли Django-застосунку.
- `Jenkinsfile` — опис CI/CD Pipeline для Jenkins.

## Опис модулів

### vpc

Створює VPC із трьома публічними та трьома приватними підмережами.

Налаштовано Internet Gateway, NAT Gateway та таблиці маршрутизації.

Мережева інфраструктура використовується з попереднього домашнього завдання через Terraform Remote State.

### eks

Створює Kubernetes-кластер в AWS EKS.

Для робочих вузлів використано EC2 `t3.medium`.

Налаштовано групу вузлів із двома екземплярами та можливістю масштабування до трьох.

Додано OIDC-провайдер для інтеграції Kubernetes із AWS IAM.

### ecr

Створює репозиторій `lesson-7-ecr` для Docker-образів Django.

Увімкнено сканування образів під час завантаження.

### s3-backend

Налаштовує S3-бакет і таблицю DynamoDB для збереження та блокування Terraform state.

### jenkins

Модуль `modules/jenkins` містить Terraform-конфігурацію для встановлення Jenkins у Kubernetes через Helm.

Основні налаштування:

- Helm-чарт Jenkins версії `5.8.27`.
- Окремий namespace `jenkins`.
- Сервіс типу `ClusterIP`.
- Постійне сховище розміром 10 GiB.
- Kubernetes Plugin для запуску агентів.
- Git Plugin для роботи з репозиторіями.
- Pipeline та інші необхідні плагіни.

Jenkins використовується для автоматизації збірки Docker-образів і оновлення Helm-конфігурації.

### argo_cd

Модуль `modules/argo_cd` містить Terraform-конфігурацію для встановлення Argo CD через Helm.

Argo CD використовується для автоматичного розгортання Django-застосунку в Kubernetes за GitOps-підходом.

Налаштовано:

- Namespace `argocd`.
- Helm-чарт `argo-cd`.
- Kubernetes Application `django-app`.
- Відстеження Helm-чарту в Git-репозиторії.
- Автоматичну синхронізацію.
- `prune: true` — видалення ресурсів, прибраних із Git.
- `selfHeal: true` — відновлення стану відповідно до Git.

## Helm-чарт Django

У папці `charts/django-app` створено Helm-чарт, який містить:

- **Deployment** — запуск Django-застосунку.
- **Service** — доступ через LoadBalancer.
- **ConfigMap** — змінні середовища Django.
- **Secret** — параметри підключення до бази даних.
- **StatefulSet** — запуск PostgreSQL.
- **HPA** — автоматичне масштабування від 2 до 6 подів при навантаженні CPU 70%.
- **values.yaml** — основні налаштування застосунку.

Docker-образ Django зберігається в Amazon ECR.

## Jenkins CI Pipeline

У кореневій папці `lesson-7` створено `Jenkinsfile`.

Pipeline описує такі етапи:

### 1. Checkout

Jenkins отримує вихідний код Django-застосунку з Git-репозиторію.

### 2. Build and Push Docker Image

Для створення Docker-образу використовується Kaniko в Kubernetes Agent.

Образ збирається з Dockerfile, що знаходиться в папці `docker/django`.

Тег Docker-образу формується на основі номера збірки Jenkins (`BUILD_NUMBER`).

Після збірки образ має бути опублікований в Amazon ECR.

### 3. Update Helm Values

Jenkins клонує GitOps-репозиторій та оновлює параметр `image.tag` у файлі:

`charts/django-app/values.yaml`

Після оновлення Jenkins створює Git-коміт і надсилає зміни до гілки `main`.

Для автентифікації GitHub передбачено Jenkins Credentials з ідентифікатором `github-gitops`.

## Argo CD та GitOps

Argo CD відстежує Git-репозиторій із Helm-чартом Django.

Після зміни тегу Docker-образу в `values.yaml` Argo CD синхронізує Kubernetes-ресурси з конфігурацією Git.

Послідовність CI/CD:

1. Зміни вихідного коду надходять у GitHub.
2. Jenkins запускає Pipeline.
3. Kaniko збирає Docker-образ.
4. Образ публікується в Amazon ECR.
5. Jenkins оновлює тег образу в Helm values.yaml.
6. Jenkins надсилає зміни до GitOps-репозиторію.
7. Argo CD виявляє зміни та синхронізує Kubernetes.
8. Django-застосунок отримує оновлену версію Docker-образу.

## Підготовка середовища

Для роботи потрібні:

- Terraform.
- AWS CLI.
- Docker.
- kubectl.
- Helm.
- Git.
- Доступ до AWS.
- GitHub-репозиторій.

Необхідно налаштувати AWS Credentials, підготувати S3 Backend і доступ до Kubernetes.

Команди Terraform виконуються з папки `lesson-7`.

## Запуск Terraform

Ініціалізація:

```bash
terraform init
```

Перевірка форматування:

```bash
terraform fmt -check -recursive
```

Перевірка конфігурації:

```bash
terraform validate
```

Перегляд змін:

```bash
terraform plan
```

Створення ресурсів:

```bash
terraform apply
```

Після створення кластера налаштувати доступ до Kubernetes:

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
```

## Запуск Helm

Отримати адресу ECR:

```bash
terraform output -raw ecr_repository_url
```

Встановити Helm-чарт Django:

```bash
helm install my-django ./charts/django-app \
  --set image.repository=АДРЕСА_ECR \
  --set config.POSTGRES_HOST=АДРЕСА_POSTGRESQL
```

Перевірити Kubernetes-ресурси:

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

Перевірити встановлення Jenkins та Argo CD:

```bash
kubectl get pods -n jenkins
kubectl get pods -n argocd
```

## Перевірка

### Terraform

Успішно виконано команди:

```bash
terraform fmt -recursive
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Результат перевірки:

```text
Success! The configuration is valid.
```

### Helm

Виконано:

```bash
helm lint ./charts/django-app
```

Результат:

```text
1 chart(s) linted, 0 chart(s) failed
```

Також виконано:

```bash
helm template django-app ./charts/django-app
```

Шаблони Kubernetes-ресурсів успішно згенеровано.

### CI/CD

Підготовлено конфігурацію Jenkins Pipeline та Argo CD для автоматизації збірки, публікації Docker-образів і розгортання Django-застосунку.

Налаштування передбачають інтеграцію GitHub, Jenkins, Amazon ECR та Kubernetes через GitOps.

## GitHub

Репозиторій:

https://github.com/voitovychn-lab/linux-homework

Гілка домашнього завдання:

`lesson-8-9`

## Висновок

У ході виконання домашніх завдань №7–9 підготовлено Terraform-конфігурацію для AWS EKS та ECR, створено Helm-чарт Django-застосунку та додано модулі Jenkins і Argo CD.

Реалізовано опис CI/CD Pipeline із використанням Kubernetes Agent, Kaniko та GitHub.

Налаштовано GitOps-підхід для автоматичного оновлення Django-застосунку через Argo CD.

Перевірки Terraform і Helm завершилися успішно. Проєкт містить необхідні конфігураційні файли для автоматизації CI/CD.


## Перевірка Jenkins Job

1. Перевірити роботу Jenkins:

   kubectl get pods -n jenkins

2. Відкрити інтерфейс Jenkins:

   kubectl port-forward svc/jenkins 8080:8080 -n jenkins

3. Перейти в браузері на http://localhost:8080.
4. Увійти в Jenkins та відкрити налаштований Pipeline Job.
5. Натиснути Build Now.
6. Відкрити Console Output і перевірити етапи Checkout, Build and Push Docker Image та Update Helm Values.
7. Перевірити новий Docker-образ в Amazon ECR та оновлений image.tag у GitHub.

## Перевірка результату в Argo CD

1. Перевірити роботу Argo CD:

   kubectl get pods -n argocd

2. Відкрити інтерфейс Argo CD:

   kubectl port-forward svc/argocd-server 8081:80 -n argocd

3. Перейти в браузері на http://localhost:8081.
4. Увійти в Argo CD та відкрити Application django-app.
5. Перевірити статуси Synced та Healthy.
6. Переглянути Kubernetes-ресурси Django.
7. Після оновлення image.tag у GitHub перевірити автоматичну синхронізацію застосунку.

## Перевірка Jenkins Job

1. Перевірити роботу Jenkins:

   kubectl get pods -n jenkins

2. Відкрити інтерфейс Jenkins:

   kubectl port-forward svc/jenkins 8080:8080 -n jenkins

3. Перейти в браузері на http://localhost:8080.
4. Увійти в Jenkins та відкрити налаштований Pipeline Job.
5. Натиснути Build Now.
6. Відкрити Console Output і перевірити етапи Checkout, Build and Push Docker Image та Update Helm Values.
7. Перевірити новий Docker-образ в Amazon ECR та оновлений image.tag у GitHub.

## Перевірка результату в Argo CD

1. Перевірити роботу Argo CD:

   kubectl get pods -n argocd

2. Відкрити інтерфейс Argo CD:

   kubectl port-forward svc/argocd-server 8081:80 -n argocd

3. Перейти в браузері на http://localhost:8081.
4. Увійти в Argo CD та відкрити Application django-app.
5. Перевірити статуси Synced та Healthy.
6. Переглянути Kubernetes-ресурси Django.
7. Після оновлення image.tag у GitHub перевірити автоматичну синхронізацію застосунку.
