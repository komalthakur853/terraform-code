terraform {
  backend "s3" {
    bucket = "nonprod-terraform-redis"
    key    = "nonprod/terraform.tfstate"
    region = "us-east-2"
  }
}
