# Розкоментувати після створення S3 та DynamoDB.
# Потім виконати: terraform init -migrate-state

# terraform {
#   backend "s3" {
#     bucket         = "nazar-voitovych-terraform-state-lesson-5"
#     key            = "lesson-5/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }