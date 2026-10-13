# Bucket comes from `terraform output state_bucket` in ../../bootstrap.
# Backend blocks cannot use variables, so edit the bucket name here.
terraform {
  backend "s3" {
    bucket       = "tfstate-482915073621-us-east-1"
    key          = "novacart/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # S3 native state locking (Terraform 1.10+)
  }
}
