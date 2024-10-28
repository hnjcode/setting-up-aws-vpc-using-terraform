terraform {
  backend "s3" {
    bucket = "hnj-tf-state"
    key    = "vpc/backend"
    region = "us-west-1"
  }
}