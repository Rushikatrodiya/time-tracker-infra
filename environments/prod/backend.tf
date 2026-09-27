terraform {
  backend "s3" {
    bucket         = "terraform-state-time-tracker"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}