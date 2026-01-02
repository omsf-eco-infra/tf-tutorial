# versions.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# variables.tf
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

# main.tf
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}

# outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
